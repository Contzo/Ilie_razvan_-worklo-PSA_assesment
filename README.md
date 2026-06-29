# Worklo — Smart Contract Assignment

## Deployed Contract

The `SalaryDistributor` contract is already deployed and live on Polygon Amoy testnet — no deployment steps required.

**Network:** Polygon Amoy Testnet
**SalaryDistributor:** `0xafa980c107e37c1e1d099b0dc4199baed07bda22`

To trigger payouts you only need to provide a **private key for an authorised payer wallet** (`PAYER_PRIVATE_KEY`) in your `.env.local`.

---

## How to Run

### Prerequisites

- Node.js 18+
- A Supabase project

### 1. Install dependencies

```bash
npm install
```

### 2. Set up environment variables

```bash
cp .env.local.template .env.local
```

Fill in the following in `.env.local`:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=sb_publishable_...
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Security
SETUP_SECRET=generate_with_openssl_rand_hex_32
CRON_SECRET=generate_with_openssl_rand_hex_32

# Contract — already deployed, just provide the payer private key
PAYER_PRIVATE_KEY=0x...
CONTRACT_ADDRESS=0xafa980c107e37c1e1d099b0dc4199baed07bda22
RPC_URL=https://rpc-amoy.polygon.technology
```

### 3. Run the database schema

Go to your Supabase dashboard → SQL Editor → paste and run `supabase/schema.sql`.

### 4. Start the app

```bash
npm run dev
```

App runs at `http://localhost:3000`.

---

## Smart Contract (Foundry)

The contract source and tests live in the `contracts/` folder as a standalone Foundry project.

```
contracts/
├── src/SalaryDistributor.sol
├── script/
│   ├── DeploySalaryDistributor.s.sol
│   └── HelperConfig.s.sol
└── test/
```

### Run tests

```bash
cd contracts
forge test
```
