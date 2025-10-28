# Odoo.sh SSH Setup - Getting Your Database Password

The SSH tunnel is working! However, PostgreSQL is requesting a password for remote connections.

## Finding Your Database Password

You need to get your Odoo.sh database password. Here are the ways to find it:

### Option 1: Check Odoo.sh Web Interface

1. Log in to your Odoo.sh dashboard
2. Navigate to your database instance
3. Look for database credentials in the settings/configuration section
4. Find the database password for your user

### Option 2: Get it from the Remote Server

Try these commands when connected via SSH:

```bash
# SSH to your Odoo.sh instance
ssh -i ~/.ssh/ai_agent_id_ed25519 23955496@zimplistic-odoo-v17-staging-23955496.dev.odoo.com

# Check Odoo configuration
cat /home/odoo/etc/odoo.conf | grep password

# Or check environment variables
env | grep -i pass

# Check PostgreSQL configuration
cat /etc/postgresql/*/main/pg_hba.conf
```

### Option 3: Reset/Generate New Password

1. Go to Odoo.sh dashboard
2. Reset your database user password
3. Use the new password in your `.env` file

## Update Your .env File

Once you have the password, add it to your `.env` file:

```env
ODOO_DB_PASSWORD=your_actual_password_here
```

## Alternative: Use Peer Authentication

If your PostgreSQL is configured with peer authentication, you might need to use a different connection method. Let me know if you find the password in the Odoo.sh dashboard, and I can help you configure it.


