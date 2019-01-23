# How to Setup and Configure Hashicorp Vault Server

This Hashicorp vault beginners tutorial will walk you through the steps on how to setup and configure a Hashicorp vault server with detailed instructions.

### Introduction

Vault is a tool from HashiCorp for securely storing and accessing secrets. Secret is nothing but all credentials like API Keys, passwords and certificates. Vault provides a unified interface to any secret while providing tight access control and recording a detailed audit log. Most of the organizations would keep their secrets in GitHub which can be seen by anyone who has access to the repo. Vault is designed in such a way that we can keep our database credentials, API keys for external services, credentials into vault and access directly from the application using APIs using various authentication mechanisms. HashiCorp Vault has more advantages than other similar services like HSMs, AWS KM, and keywhiz.
Most Common Use Cases of Vault

### Following are the common use cases for Vault

    A bare minimum vault can be used as a general secret storage, It is a great tool to store environment variables, DB credentials and API keys.
    Vault is a good fit for storing credentials that employees share to access web services. The audit log mechanism lets you know what secrets an employee accessed and when an employee leaves, it is easier to roll keys and understand which keys have and haven’t been rolled.
    The “dynamic secrets” feature of Vault is ideal for scripts: It can generate an access key for the duration of a script runtime which is like temporary access token.
    In addition to being able to store secrets, Vault can be used to encrypt/decrypt data that is stored elsewhere. The primary use of this is to allow applications to encrypt their data being in the primary data store.

### Key Vault Features

#### Secure Secret Storage: 
     
     Arbitrary key/value secrets can be stored in Vault. It encrypts the secret and stores in a persistent backend storage. 
     Vault supports multiple storage backends such as a local disk, consul or cloud storage like AWS S3 or GCS bucket.

#### Dynamic Secrets: 
     
     Vault can generate secrets on-demand for some systems, such as AWS or SQL databases. 
     For example, when an application needs to access an S3 bucket, it asks Vault for credentials, and Vault will generate an AWS keypair with valid permissions on demand. 
     After creating these dynamic secrets, Vault will also automatically revoke them after the lease is up.
     
#### Data Encryption: 
     
     Vault is capable of encrypting and decrypting data without storing it. 
     This allows security teams to define encryption parameters and developers to store encrypted data in a location such as SQL without having to design their own encryption methods.

#### Leasing and Renewal: 

     Secrets in vaults are associated with the lease, end of the lease vault will revoke the secrets, We can renew lease using renew APIs.

#### Revocation: 
    
     Vault has built-in support for secret revocation.     

## Setup and configure Vault Server on Linux

Follow the steps given below for setting up the vault server.

Step 1:  Download the latest version of vault binary zip file from vault release page and unzip it.

```
cd /opt/
sudo wget https://releases.hashicorp.com/vault/0.10.3/vault_0.10.3_linux_amd64.zip
sudo unzip vault_0.10.3_linux_amd64.zip -d .
```
Step 2: Copy vault binary into /usr/bin. This will allow us to execute vault binary systemwide.

` sudo cp vault /usr/bin/ `

Step 3:  Create a vault config directory under /etc,  a vault data directory and logs directory.

```	
sudo mkdir /etc/vault
sudo mkdir /vault-data
sudo mkdir -p /logs/vault/
```

Step 4: Create a config.json file and add the vault configuration.

` sudo vi /etc/vault/config.json `
	
Add the below configuration to the file. Vault supports both JSON and HCL formats. Here we are using JSON format.

Note: replace 10.128.0.2 with your vault host public/private IP.

```
{
"listener": [{
"tcp": {
"address" : "0.0.0.0:8200",
"tls_disable" : 1
}
}],
"api_addr": "http://10.128.0.2:8200",
"storage": {
    "file": {
    "path" : "/vault-data"
    }
 },
"max_lease_ttl": "10h",
"default_lease_ttl": "10h",
"ui":true
}

```

" max_lease_ttl"  – Specifies the maximum possible lease duration for tokens and secrets. This is specified using a label suffix like “30s” or “1h”.

"default_lease_ttl" – Specifies the default lease duration for tokens and secrets. This is specified using a label suffix like “30s” or “1h”. This value cannot be larger than max_lease_ttl.

Note: This config file is created specifically to use filesystem backend, You can even use consul cluster backend, S3 or GCS (Google cloud storage) backend like shown below,

Vault Consul Backend Config


     
     
     
