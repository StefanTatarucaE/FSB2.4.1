/*
SUMMARY: Deployment of a Private DNS Zone.
DESCRIPTION: Deploy a Private DNS Zone in the desired Azure region.
AUTHOR/S: surbhi.2.sharma@eviden.com
VERSION: 0.0.1
*/

//PARAMETERS
@description('The name of the zone, for example, contoso.com.')
param name string

@description('Tag/s to assign to this resource.')
param tags object

@description('Create A record set.')
param aRecordSet array

@description('Create CNAME record set.')
param cnameRecordSet array

@description('Create MX record set.')
param mxRecordSet array

@description('Create PTR record set.')
param ptrRecordSet array

@description('Create SRV record set.')
param srvRecordSet array

@description('Create TXT record set.')
param txtRecordSet array

@description('Create AAAA record set.')
param aaaaRecordSet array

// VARIABLES
// None

// RESOURCES
// Creating private DNS Zone using the name provided.
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global' //This is always global.
  tags: tags
  properties: {} //This object doesn't contain any properties to set during deployment. All properties are ReadOnly.
}

// Creating ipv4 'A' DNS Record - Alias record to ipv4 address.
resource ipv4Record 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for ipv4rr in aRecordSet: if (ipv4rr.createRecordA) {
  name: ipv4rr.name
  parent: privateDnsZone
  properties: {
    aRecords: ipv4rr.ipv4Address
    ttl: ipv4rr.ttl
  }
}]

// Creating 'CNAME' DNS Record - Link your subdomain to another record.
resource cnameRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = [for cname in cnameRecordSet: if (cname.createRecordCname) {
  name: cname.name
  parent: privateDnsZone
  properties: {
    cnameRecord: {
      cname: cname.cname
    }
    ttl: cname.ttl
  }
}]

// Creating 'MX' DNS Record - Mail exchange records.
resource mxRecord 'Microsoft.Network/privateDnsZones/MX@2020-06-01' = [for mx in mxRecordSet: if (mx.createRecordMx) {
  name: mx.name
  parent: privateDnsZone
  properties: {
    mxRecords: mx.exchange
    ttl: mx.ttl
  }
}]

// Creating 'ptrRecords' DNS Record - Pointer record type.
resource ptrRecord 'Microsoft.Network/privateDnsZones/PTR@2020-06-01' = [for ptr in ptrRecordSet: if(ptr.createRecordPtr) {
  name: ptr.name
  parent: privateDnsZone
  properties: {
    ptrRecords: ptr.ptrValue
    ttl: ptr.ttl
  }
}]

// Creating 'srvRecords' DNS Record - Service records.
resource srvRecord 'Microsoft.Network/privateDnsZones/SRV@2020-06-01' = [for srv in srvRecordSet: if(srv.createRecordSrv) {
  name:srv.name
  parent: privateDnsZone
  properties: {
    srvRecords: srv.srvValue
    ttl:srv.ttl
  }
}]

// Creating 'txtRecords' DNS Record - Text record type.
resource txtRecord 'Microsoft.Network/privateDnsZones/TXT@2020-06-01' = [for txt in txtRecordSet: if(txt.createRecordTxt) {
  name:txt.name
  parent: privateDnsZone
  properties: {
    txtRecords: txt.txtValue
    ttl: txt.ttl
  }
}]

// Creating ipv6 'AAAA' DNS Record - Alias record to ipv4 address.
resource ipv6Record 'Microsoft.Network/privateDnsZones/AAAA@2020-06-01' = [for ipv6rr in aaaaRecordSet: if (ipv6rr.createRecordAaaa) {
  name: ipv6rr.name
  parent: privateDnsZone
  properties: {
    aaaaRecords: ipv6rr.ipv6Address
    ttl: ipv6rr.ttl
  }
}]

// OUTPUTS
@description('The resource name of the Private DNS Zone.')
output privateDNSZoneName string = privateDnsZone.name

@description('The resource id of the Private DNS Zone.')
output privateDNSZoneResourceId string = privateDnsZone.id
