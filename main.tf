provider "aws" {
  region = "us-east-1"
}

###########  VPC block ##################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "mainVPC"
  }
}

##########  Internet Gateway ############

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main1"
  }
}

######### Subnet #################

resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public"
  }
}


resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Private"
  }
}



############ Route Table ###################
resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.main.id

  route = []
  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "Private" {
  vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "Private"
  }
}


########### Route #####################

resource "aws_route" "Public" {
  route_table_id         = aws_route_table.Public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  depends_on             = [aws_route_table.Public]
}


######### Security Group ###################

resource "aws_security_group" "Public_Sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "All traffic"
      from_port        = 0    # All ports
      to_port          = 0    # All Ports
      protocol         = "-1" # All traffic
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "Public_Sg"
  }
}

resource "aws_security_group" "Private_Sg" {
  name        = "only from subnet"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "All traffic"
      from_port        = 0    # All ports
      to_port          = 0    # All Ports
      protocol         = "-1" # All traffic
      cidr_blocks      = ["10.0.1.0/24"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "Private_Sg"
  }
}


################# Route Table Association #################

resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "Private" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.Private.id
}
################### KEY ################################
