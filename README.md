# Worklo — Smart Contract Assignment

## Deployed Contract

**Network:** Polygon Amoy Testnet
**SalaryDistributor:** `0xafa980c107e37c1e1d099b0dc4199baed07bda22`

---

## How to Run

### Prerequisites

- Node.js 18+
- A free [Supabase](https://supabase.com) project
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (for contract work)

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

# Contract
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

The contract lives in the `contracts/` folder as a standalone Foundry project.

```
contracts/
├── src/SalaryDistributor.sol     # main contract
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

### Deploy to Polygon Amoy

Create `contracts/.env`:

```bash
DEPLOYER_PRIVATE_KEY=0x...   # deployer wallet private key (becomes contract owner)
PAYER_ADDRESS=0x...          # wallet that will be authorised to call distribute()
```

Then run:

```bash
cd contracts
forge script script/DeploySalaryDistributor.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --env-file .env \
  --broadcast
```

The script deploys the contract and immediately authorises the payer address by calling `setPayer()`.

---

## What I'd Improve With More Time

- **Frontend validation** — validate Ethereum addresses and Wei amounts client-side before submitting, with clearer error messages.
- **Contract verification** — verify the contract on Polygonscan so the ABI is publicly readable.
- **Payout history** — store past transactions in Supabase and display them on the payouts page.
- **Amount input UX** — let users input amounts in MATIC rather than raw Wei and convert before sending.
