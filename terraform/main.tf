resource "azurerm_resource_group" "rg" {
	name		=	"${var.prefix}-rg"
	location	=	var.location
}

resource "azurerm_network_security_group" "nsg" {
	name = "${var.prefix}-nsg"
	location	= azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

	security_rule {
		name						=	"Allow-SSH"
		priority					=	100
		direction					=	"Inbound"
		access						=	"Allow"
		protocol					=	"Tcp"
		source_port_range			=	"*"
		destination_port_range		=	"22"
		source_address_prefix		=	"*"
		destination_address_prefix	=	"*"
	}

	security_rule {
		name						=	"Allow-HTTP"
		priority					=	101
		direction					=	"Inbound"
		access						=	"Allow"
		protocol					=	"Tcp"
		source_port_range			=	"*"
		destination_port_range		=	"80"
		source_address_prefix		=	"*"
		destination_address_prefix	=	"*"
	}
	security_rule {
		name						=	"Allow-HTTPS"
		priority					=	102
		direction					=	"Inbound"
		access						=	"Allow"
		protocol					=	"Tcp"
		source_port_range			=	"*"
		destination_port_range		=	"443"
		source_address_prefix		=	"*"
		destination_address_prefix	=	"*"
	}
}

resource "azurerm_virtual_network" "vnet" {
	name					=	"${var.prefix}-vnet"
	address_space			=	["10.10.0.0/16"]
	location				=	azurerm_resource_group.rg.location
	resource_group_name	=	azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
	name					=	"${var.prefix}-subnet"
	resource_group_name		=	azurerm_resource_group.rg.name
	virtual_network_name	=	azurerm_virtual_network.vnet.name
	address_prefixes		=	["10.10.1.0/24"]

	depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "pip"{
	count				=	var.vm_count
	name				=	"${var.prefix}-pip-${count.index}"
	location			=	azurerm_resource_group.rg.location
	resource_group_name	=	azurerm_resource_group.rg.name
	allocation_method	=	"Static"
	sku					=	"Standard"
}

resource "azurerm_network_interface" "nic" {
	count 				=	var.vm_count
	name				=	"${var.prefix}-nic-${count.index}"
	location			=	azurerm_resource_group.rg.location
	resource_group_name	=	azurerm_resource_group.rg.name

	ip_configuration {
		name						=	"Internal"
		subnet_id					=	azurerm_subnet.subnet.id
		private_ip_address_allocation	=	"Dynamic"
		public_ip_address_id		=	azurerm_public_ip.pip[count.index].id
	}
}

resource "azurerm_network_interface_security_group_association" "nic_nsg"{
	count	= var.vm_count
	network_interface_id = azurerm_network_interface.nic[count.index].id
	network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
	count	=	var.vm_count
	name	=	"${var.prefix}-vm-${count.index}"
	resource_group_name				=	azurerm_resource_group.rg.name
	location						=	azurerm_resource_group.rg.location
	size							=	var.vm_size
	admin_username					=	var.admin_username
	disable_password_authentication	=	true
	network_interface_ids			=	[azurerm_network_interface.nic[count.index].id]

	dynamic "admin_ssh_key" {
		for_each = var.ssh_public_keys
		content {
			username   = var.admin_username
			public_key = admin_ssh_key.value
		}
	}

	os_disk {
		caching              = "ReadWrite"
		storage_account_type = "Standard_LRS"
	}

	source_image_reference {
		publisher = "Canonical"
		offer     = "ubuntu-24_04-lts"
		sku       = "server"
		version   = "latest"
	}
}

resource "local_file" "ansible_inventory" {
	content = templatefile("${path.module}/inventory.tftpl", {
		ips		= azurerm_public_ip.pip[*].ip_address
		ssh_user = var.admin_username
	})
	filename	= "${path.module}/../ansible/inventory.ini"
	depends_on	= [azurerm_linux_virtual_machine.vm]
}
