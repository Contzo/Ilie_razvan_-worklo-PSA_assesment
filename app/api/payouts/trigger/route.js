import { NextResponse } from 'next/server';
import { ethers } from 'ethers';
import { requireAuthentication, requireSuperadmin } from '@/lib/server-guards';
import { logger } from '@/lib/debug-logger';
import { SALARY_DISTRIBUTOR_ABI } from '@/lib/salaryDistributorAbi';

export async function POST(request) {
  try {
    const user = await requireAuthentication(request);
    await requireSuperadmin(user);

    let body;
    try {
      body = await request.json();
    } catch (_e) {
      return NextResponse.json({ error: 'Invalid request body' }, { status: 400 });
    }

    const { recipients, amountsWei } = body;

    if (!Array.isArray(recipients) || !Array.isArray(amountsWei)) {
      return NextResponse.json({ error: 'recipients and amountsWei must be arrays' }, { status: 400 });
    }
    if (recipients.length === 0) {
      return NextResponse.json({ error: 'Batch cannot be empty' }, { status: 400 });
    }
    if (recipients.length !== amountsWei.length) {
      return NextResponse.json({ error: 'recipients and amountsWei length mismatch' }, { status: 400 });
    }

    const privateKey = process.env.PAYER_PRIVATE_KEY;
    const contractAddress = process.env.CONTRACT_ADDRESS;

    if (!privateKey || !contractAddress) {
      return NextResponse.json({ error: 'PAYER_PRIVATE_KEY or CONTRACT_ADDRESS not configured' }, { status: 500 });
    }

    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || 'http://127.0.0.1:8545');
    const wallet = new ethers.Wallet(privateKey, provider);
    const contract = new ethers.Contract(contractAddress, SALARY_DISTRIBUTOR_ABI, wallet);

    const totalWei = amountsWei.reduce((sum, a) => sum + BigInt(a), BigInt(0));

    const tx = await contract.distribute(recipients, amountsWei, { value: totalWei });
    const receipt = await tx.wait();

    logger.info('Payout distributed', { txHash: receipt.hash, recipients: recipients.length });

    return NextResponse.json({ txHash: receipt.hash });
  } catch (error) {
    if (error.name === 'ForbiddenError' || error.name === 'AuthenticationError') {
      return NextResponse.json({ error: error.message }, { status: 403 });
    }
    logger.error('Error in POST /api/payouts/trigger', {}, error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
