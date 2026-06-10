# Student Companion Backend

Express REST API for the Student Companion Flutter application.

## Current Backend
This backend currently includes the Express scaffold, database connection helper, SQL setup scripts, schema and seed files, and a health endpoint.

## Environment Variables
Create `backend/.env` from `.env.example`.

```env
PORT=4242
DATABASE_URL="your_neon_postgresql_connection_string"
DATABASE_URL_DIRECT=
```

Use `DATABASE_URL` for the Neon serverless connection used by API traffic. Use `DATABASE_URL_DIRECT` only if you want to run schema and seed scripts from the terminal.

## Database Setup
```bash
npm install
npm run db:setup
```

The setup command runs:

```bash
node scripts/run_sql_file.js database/schema.sql
node scripts/run_sql_file.js database/seed.sql
```

## Start the Backend
```bash
npm install
node src/server.js
```

## Health Endpoint
```text
GET /api/health
```

Local URL:

```text
http://localhost:4242/api/health
```

If the API is running but Neon is not configured, the endpoint returns `503` with a safe message.

## Troubleshooting
- Confirm `.env` exists in `backend/`.
- Confirm `DATABASE_URL` uses the Neon connection string.
- Confirm the `confessions` table exists in Neon.
- Use HTTPS for the backend URL before building the final release APK.
