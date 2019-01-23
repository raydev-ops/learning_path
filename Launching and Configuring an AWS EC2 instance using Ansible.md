# Launching and Configuring an AWS EC2 instance using Ansible

First of all, we will discuss the basic requirements that need to be initialized to launch an EC2 instance. We will need the following details:

    region => The region in which the instance needs to be launched.
    security group => The security group to be associated with the instance.
    image-id => The AMI id by which the instance is to be launched.
    instance-type => The type of the instance.
    key-pair => The Pem file to authenticate the login process.
    count => The number of instances to be launched.
    Role => The IAM role to be associated with the EC2 instance.
    volume-size => The size of the EBS volumes to be attached.

After setting the variables we are good to go. The given below are the tasks of the ansible playbook which we are going to create:

1. Launching an EC2 instance

Ansible uses its ec2 module to launch the instance. The following is the task:

```	
- name: Launching an EC2 Instance
  local_action: ec2
       instance_type={{ instance_type}}
       image={{ ami }}
       region={{ region }}
       keypair={{ pem }}
       count={{count}}
       instance_profile_name={{ instance_profile_name }}
       group={{ security_group }}
       wait=true
       volumes={{volumes}}
 register: ec2

```
The value of the variables will be passed when executing the playbook. The “{{ }}” is being used to evaluate the value of the variable. The statement “wait=true” is used to let ansible wait for the instance to come. The statement “register: ec2″ register the output in ec2 variable so that we can run the query to find out different properties of the instance.

2. Allocating Elastic IP to EC2 instance

```	
- name: Associating after allocating elastic IP
        eip:
          in_vpc: yes
          reuse_existing_ip_allowed: yes
          state: present
          region: "{{ region }}"
          device_id: "{{ ec2.instance_id[0] }}"
  register: elastic_ip

```	

This task is used to allocate Elastic IP to the instance. Here, the elastic IP is associated with the instance and set in the variable “elastic_ip”.

3. Waiting for the instance to come

```	
	
- name: Waiting for the instance to come
        local_action: wait_for
                      host={{ item.private_ip }}
                      state=started
                      port=22
        with_items: ec2.instances

```	

This playbook task is used to wait for the instance to come. The instance check is done until the instance comes in the available state. Here “with_items: ec2.instances” is used to create a loop. The ansible waits for the instance to come and become available by looping at port 22.

4. Adding tags to the EC2 instance

```		
- name: Adding tags to the EC2 Instance"
        local_action: ec2_tag
                      region={{ region }}
                      resource={{ item.id }}
                      state=present
        with_items: ec2.instances
        args:
          tags:
            Name: "{{ name }}"
            Env: "{{ Env }}"
            Type: microservice
  register: tag

```	
This task is used to add tags to the instances. The local action ec2_tag is used. The item ec2.instances is used to pick out instance id and region. The tags are added as Name: “{{ name }}”, where the value of the name will be passed from outside. The tags added will be initialized to by using “register: tag”.

By using these above tasks in the  ansible playbook the instance will be created and configured. Make sure the host from which you are running the playbook must have enough permissions to launch the EC2 instance.

The complete ansible playbook to launch instance using above tasks is as follows:

```		
---
- name: Configuring the EC2 Instance
  hosts: localhost
  connection: local
  vars:
       count: {{ count }}
       volumes:
               - device_name: /dev/sda1
                 volume_size: {{ volume-size }}    
 
- name: Launching an EC2 Instance
  local_action: ec2
  instance_type={{ instance_type}}
  image={{ ami }}
  region={{ region }}
  keypair={{ pem }}
  count={{count}}
  instance_profile_name={{ instance_profile_name }}
  group={{ security_group }}
  wait=true
  volumes={{volumes}}
  register: ec2
 
- name: Associating after allocating elastic IP
  eip:
      in_vpc: yes
      reuse_existing_ip_allowed: yes
      state: present
      region: "{{ region }}"
      device_id: "{{ ec2.instance_id[0] }}"
      register: elastic_ip
 
- name: Waiting for the instance to come
  local_action: wait_for
              host={{ item.private_ip }}
              state=started
              port=22
  with_items: ec2.instance
 
- name: Adding tags to the EC2 Instance"
  local_action: ec2_tag
              region={{ region }}
              resource={{ item.id }}
              state=present
  with_items: ec2.instances
  args:
   tags:
       Name: "{{ name }}"
       Env: "{{ Env }}"
       Type: microservice
  register: tag

```	

The playbook has been created. Now, for example, the playbook should be run as:


'ansible-playbook playbook_name.yml –extra-vars volume-size=10 -e instance_type=t2.micro -e region=us=east-1 -e keypair=sample.pem -e count=1 '



