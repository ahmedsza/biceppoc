This is a bicep template POC that implements
- APIM in internal mode
- App gateway that exposes the APIM. It uses self signed certs
- 2 app services with private link
- sql azure with private link
- private dns zones for APIM and app service
- user managed identity
- have not implemented app gateway with app service
- azure monitor workspace with app insights
- there are no custom domains specified for APIM. 
- the self signed certs script is in createselfsignedcert.txt. It is a powershell script
- you can change apimdemo.net to a domain that suit you
- in the wmain.bicep setup the names of the parameter
- the base64 value will come from the ps script run
- the domain name must match to what is in the ps script so api.<domainname>.net
- run something like below to execute. it takes awhile


az deployment sub create --location southafricanorth --template-file wmain.bicep 