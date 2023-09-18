locals {
  azs = slice(data.aws_availability_zone.avaiable.names,0,2) # to get the first two azs in a list slice perform like extract some data 
  
}