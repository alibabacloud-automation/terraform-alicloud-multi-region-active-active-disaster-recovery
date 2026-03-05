# Complete Multi-Region Infrastructure Example

This example demonstrates the full capabilities of the multi-region infrastructure module, including:

- **Multi-region VPCs** with multiple availability zones
- **High-availability ECS instances** with load balancers
- **PolarDB clusters** in both regions with replication
- **Application Load Balancers** with health checks
- **Cross-region connectivity** via CEN
- **Database synchronization** via DTS
- **Automated application deployment** with monitoring

## Architecture

```
Hangzhou Region                    Shanghai Region
┌─────────────────────────────────┐ ┌─────────────────────────────────┐
│ VPC (10.0.0.0/16)               │ │ VPC (10.1.0.0/16)               │
│ ┌─────────────┬─────────────────┐│ │┌─────────────┬─────────────────┐ │
│ │   Zone A    │     Zone B      ││ ││   Zone A    │     Zone B      │ │
│ │┌───────────┐│┌───────────────┐││ ││┌───────────┐│┌───────────────┐│ │
│ ││Web Subnet ││││Web Subnet    │││ │││Web Subnet ││││Web Subnet    ││ │
│ ││ECS + App  ││││ECS + App     │││ │││ECS + App  ││││ECS + App     ││ │
│ │└───────────┘││└───────────────┘││ ││└───────────┘││└───────────────┘│ │
│ │             ││┌───────────────┐││ ││             ││┌───────────────┐│ │
│ │             │││DB Subnet     │││ │││             │││DB Subnet     ││ │
│ │             │││PolarDB       │││ │││             │││PolarDB       ││ │
│ │             ││└───────────────┘││ ││             ││└───────────────┘│ │
│ └─────────────┴─────────────────┘│ │└─────────────┴─────────────────┘ │
│ ┌─────────────────────────────────┐│ │┌─────────────────────────────────┐ │
│ │            ALB                  ││ ││            ALB                  │ │
│ └─────────────────────────────────┘│ │└─────────────────────────────────┘ │
└─────────────────────────────────────┘ └─────────────────────────────────────┘
                    │                                       │
                    └─────────────┬─────────────────────────┘
                                  │
                           ┌─────────────┐
                           │     CEN     │
                           └─────────────┘
                                  │
                           ┌─────────────┐
                           │     DTS     │
                           └─────────────┘
```

## Features Demonstrated

### Network Architecture
- **Multi-AZ deployment** for high availability
- **Separate subnets** for web and database tiers
- **Security groups** with tier-specific rules
- **Cross-region connectivity** via CEN transit routers

### Compute Resources
- **Multiple ECS instances** per region for redundancy
- **Automated application deployment** with custom scripts
- **Load balancing** across multiple instances
- **Health checks** and monitoring

### Database Services
- **PolarDB clusters** in both regions
- **Database accounts** and privilege management
- **Cross-region replication** via DTS
- **Security IP whitelisting**

### Load Balancing
- **Application Load Balancers** in both regions
- **Multi-AZ server groups** for high availability
- **Health check configuration**
- **Internet-facing endpoints**

## Prerequisites

1. **Alibaba Cloud Account** with sufficient quotas
2. **Terraform** >= 1.0
3. **Alibaba Cloud Provider** >= 1.210.0
4. **Appropriate permissions** for all services used

## Resource Requirements

This example creates significant resources. Ensure you have adequate quotas:

- **ECS Instances**: 4 instances (c6.large)
- **PolarDB Clusters**: 2 clusters (x4.large nodes)
- **ALB Instances**: 2 load balancers
- **CEN**: 1 instance with transit routers
- **DTS**: 1 synchronization instance

## Usage

### 1. Prepare Environment

```bash
cd examples/complete
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
ecs_password = "YourSecurePassword123!"
db_password  = "YourDatabasePassword123!"
admin_cidr   = "YOUR_IP_ADDRESS/32"  # Replace with your IP
```

Or set environment variables:

```bash
export TF_VAR_ecs_password="YourSecurePassword123!"
export TF_VAR_db_password="YourDatabasePassword123!"
export TF_VAR_admin_cidr="YOUR_IP_ADDRESS/32"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Verify Deployment

After deployment, verify the setup:

```bash
# Get load balancer DNS names
terraform output alb_load_balancer_dns_names

# Test application endpoints
curl http://<alb-dns-name>/
curl http://<alb-dns-name>/health

# Check database connectivity (from ECS instances)
mysql -h <polardb-endpoint> -u appuser -p
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| ecs_password | Password for ECS instances | string | - | yes |
| db_password | Password for PolarDB accounts | string | - | yes |
| admin_cidr | CIDR for admin SSH access | string | "0.0.0.0/0" | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_ids | VPC IDs in both regions |
| ecs_instance_ids | ECS instance IDs |
| ecs_instance_public_ips | ECS public IP addresses |
| ecs_instance_private_ips | ECS private IP addresses |
| polardb_cluster_ids | PolarDB cluster IDs |
| polardb_cluster_endpoints | Database connection endpoints |
| alb_load_balancer_ids | Load balancer IDs |
| alb_load_balancer_dns_names | Load balancer DNS names |
| security_group_ids | Security group IDs |
| cen_instance_id | CEN instance ID |
| transit_router_ids | Transit router IDs |
| dts_instance_id | DTS instance ID |

## Testing the Deployment

### 1. Application Testing

```bash
# Test web application
ALB_DNS=$(terraform output -raw alb_load_balancer_dns_names | jq -r '.main_alb_hz')
curl http://$ALB_DNS/

# Test health endpoint
curl http://$ALB_DNS/health
```

### 2. Database Testing

```bash
# Connect to ECS instance
ECS_IP=$(terraform output -raw ecs_instance_public_ips | jq -r '.web_server_hz_1')
ssh root@$ECS_IP

# Test database connection
DB_ENDPOINT=$(terraform output -raw polardb_cluster_endpoints | jq -r '.main_cluster_hz')
mysql -h $DB_ENDPOINT -u appuser -p -e "SHOW DATABASES;"
```

### 3. Cross-Region Connectivity

```bash
# From Hangzhou ECS, ping Shanghai ECS
ssh root@<hangzhou-ecs-ip>
ping <shanghai-ecs-private-ip>

# Test cross-region database access
mysql -h <shanghai-db-endpoint> -u appuser -p
```

## Monitoring and Maintenance

### Application Monitoring

The deployment includes built-in monitoring:

- **Health checks** via ALB
- **Application monitoring** script running every 5 minutes
- **Log rotation** for application logs
- **System metrics** collection

### Database Monitoring

Monitor database performance:

```bash
# Check PolarDB cluster status in console
# Monitor DTS synchronization status
# Review database performance metrics
```

### Infrastructure Monitoring

Use Alibaba Cloud monitoring services:

- **CloudMonitor** for resource metrics
- **Log Service** for centralized logging
- **Application Real-Time Monitoring Service** for APM

## Cost Optimization

### Estimated Monthly Costs

- **ECS Instances**: ~$200-400 (4 × c6.large)
- **PolarDB Clusters**: ~$600-1200 (2 × x4.large)
- **ALB**: ~$20-40 (2 instances)
- **CEN**: ~$10-20 (data transfer costs)
- **DTS**: ~$50-100 (synchronization)

**Total**: ~$880-1760 USD/month

### Cost Optimization Tips

1. **Right-size instances** based on actual usage
2. **Use Reserved Instances** for production workloads
3. **Implement auto-scaling** for variable workloads
4. **Monitor and optimize** data transfer costs
5. **Regular cleanup** of unused resources

## Security Considerations

### Network Security

- **Private subnets** for database tier
- **Security groups** with minimal required access
- **Admin access** restricted to specific CIDR
- **Cross-region encryption** via CEN

### Database Security

- **Strong passwords** for database accounts
- **IP whitelisting** for database access
- **Encrypted connections** between applications and databases
- **Regular security updates**

### Application Security

- **Security headers** in nginx configuration
- **Regular system updates** via automated scripts
- **Log monitoring** for security events
- **Access control** via security groups

## Troubleshooting

### Common Issues

1. **Resource quota limits**: Check and request quota increases
2. **Network connectivity**: Verify CEN and security group configurations
3. **Database connection**: Check IP whitelists and account permissions
4. **Load balancer health checks**: Verify application endpoints

### Debug Commands

```bash
# Check ECS instance status
terraform output ecs_instance_ids
# Use Alibaba Cloud console to check instance status

# Test network connectivity
ssh root@<ecs-ip>
ping <target-ip>
telnet <db-endpoint> 3306

# Check application logs
ssh root@<ecs-ip>
tail -f /var/log/app/monitor.log
systemctl status nginx
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including databases. Ensure you have backups if needed.

## Next Steps

1. **Implement monitoring** with CloudMonitor and Log Service
2. **Add auto-scaling** for ECS instances
3. **Configure SSL certificates** for HTTPS
4. **Implement CI/CD pipeline** for application deployment
5. **Add backup and disaster recovery** procedures
6. **Implement infrastructure as code** best practices

## Support

For issues and questions:
- Review the logs in `/var/log/app/`
- Check Alibaba Cloud console for resource status
- Verify network connectivity and security groups
- Contact support if needed