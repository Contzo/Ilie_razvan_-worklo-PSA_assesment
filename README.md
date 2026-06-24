# Worklo — Smart Contract Assignment

Welcome to the Worklo Smart Contract Assignment! 

Worklo is a PSA (Professional Services Automation) platform for managing projects, tasks, time tracking, and client relationships. In this exercise you'll build a real on-chain salary distribution feature — writing a Solidity contract, wiring it into the backend, and triggering it from the UI.

Focus on quality over completeness. Submit what you have when time is up.

If you have any questions, feel free to reach out — we're happy to clarify anything.
                                   
## Time Consideration

This assignment is scoped for 4–5 hours. If you hit that limit, submit what you have and use this `README.md` to describe what you'd finish next.

## Getting Started

You'll need Node.js 18+ and a free Supabase project.   
   
```bash
# 1. Fork this repo and clone your fork
npm install

# 2. Set up environment variables
cp .env.local.template .env.local
# Fill in your Supabase URL and keys in .env.local

# 3. Run the database schema
# → Supabase dashboard → SQL Editor → paste and run supabase/schema.sql

# 4. Start the app
npm run dev              # Next.js on http://localhost:3000
```

## Task Overview

Build a `SalaryDistributor` smart contract and wire it into the running Worklo platform so a superadmin can trigger a payout from the UI.

**Part A — Smart contract**

- Write `contracts/SalaryDistributor.sol` using Solidity ^0.8.20 and OpenZeppelin
- Implement `distribute(address[], uint256[])` restricted to authorised payer addresses
- Add owner-only `setPayer`, `pause`, and `unpause` — both `distribute` and `setPayer` must revert when paused
- Use custom errors for: mismatched arrays, empty batch, zero address, insufficient `msg.value`
- Refund excess `msg.value` to `msg.sender`
- Emit `Distributed(address indexed recipient, uint256 amount)` and `BatchCompleted(uint256 totalAmount, uint256 recipientCount)`
- Write tests covering: happy path, unauthorised caller, paused state, mismatched arrays, excess refund

**Part B — API route**

Add `app/api/payouts/trigger/route.js` following the existing route patterns in `app/api/`:

- Auth: superadmin only — use `requireAuthentication` from `lib/server-guards.ts`
- Body: `{ recipients: string[], amountsWei: string[] }`
- Call `distribute()` on the deployed contract via ethers.js v6 using env vars `PAYER_PRIVATE_KEY` and `CONTRACT_ADDRESS`
- Return `{ txHash }`


**Part C — Frontend**

Add `app/admin/payouts/page.tsx`:

- Guard: redirect non-superadmin users to `/dashboard`
- Form with recipient addresses and amounts inputs
- **Trigger Payout** button that calls `POST /api/payouts/trigger` via `apiFetch()`

**[Bonus]** Deploy to Polygon Amoy testnet and include the contract address in your README.

## How We Evaluate

- Smart contract — security, custom errors, OZ usage | 40% |
- API route — auth guard, ethers.js integration, error handling | 25% |
- Frontend — TypeScript, loading/error states, existing patterns | 20% |
- README — reasoning on key decisions and trade-offs | 15% |

## Submission Guidelines

Don't open a PR to this repo. Share your fork URL.

In your forked repository, include a README that explains:

- How to run your project.
- What you'd improve or do differently if you had more time.

Make sure your code runs locally based on the instructions in your README.
