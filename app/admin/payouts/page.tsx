'use client';

import { useAuth } from '@/lib/hooks/useAuth';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { CheckCircle, AlertCircle } from 'lucide-react';
import { isSuperadmin } from '@/lib/rbac';
import { apiFetch } from '@/lib/api-config';

interface Message {
  type: 'success' | 'error';
  text: string;
}

export default function PayoutsPage() {
  const { userProfile, loading } = useAuth();
  const router = useRouter();
  const [recipients, setRecipients] = useState('');
  const [amounts, setAmounts] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<Message | null>(null);

  // Redirect non-superadmins away once auth has resolved
  useEffect(() => {
    if (!loading && userProfile && !isSuperadmin(userProfile)) {
      router.push('/dashboard');
    }
  }, [userProfile, loading, router]);

  // Show spinner while auth is in progress
  if (loading || !userProfile) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="mx-auto h-8 w-8 animate-spin rounded-full border-b-2 border-gray-900" />
      </div>
    );
  }


  const handleTriggerPayout = async () => {
    // Parse each textarea into a clean array, stripping whitespace and blank lines
    const recipientList = recipients.split('\n').map((s) => s.trim());
    const amountList = amounts.split('\n').map((s) => s.trim());

    if (recipientList.length === 0 || amountList.length === 0) {
      setMessage({ type: 'error', text: 'Please enter at least one recipient and amount.' });
      return;
    }
    if (recipientList.length !== amountList.length) {
      setMessage({ type: 'error', text: 'Number of recipients and amounts must match.' });
      return;
    }

    setIsLoading(true);
    setMessage(null);
    try {
      // POST to the API route which calls distribute() on the deployed contract
      const res = await apiFetch('/api/payouts/trigger', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ recipients: recipientList, amountsWei: amountList }),
      });
      const data = await res.json();
      if (res.ok && data.txHash) {
        setMessage({ type: 'success', text: `Payout submitted! Tx: ${data.txHash}` });
        setRecipients('');
        setAmounts('');
      } else {
        setMessage({ type: 'error', text: data.error || 'Payout failed.' });
      }
    } catch {
      setMessage({ type: 'error', text: 'Failed to trigger payout. Please try again.' });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container mx-auto max-w-xl space-y-6 px-4 py-6">
      <div>
        <h1 className="text-3xl font-bold">Trigger Payout</h1>
        <p className="text-muted-foreground mt-1">
          Distribute salaries on-chain via the SalaryDistributor contract.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Payout Details</CardTitle>
          <CardDescription>Enter one recipient address and amount (in Wei) per line.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="recipients">Recipient Addresses</Label>
            <Textarea
              id="recipients"
              placeholder={'0xAbc...\n0xDef...'}
              value={recipients}
              onChange={(e) => setRecipients(e.target.value)}
              disabled={isLoading}
              rows={4}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="amounts">Amounts (Wei)</Label>
            <Textarea
              id="amounts"
              placeholder={'1000000000000000000\n500000000000000000'}
              value={amounts}
              onChange={(e) => setAmounts(e.target.value)}
              disabled={isLoading}
              rows={4}
            />
          </div>
          <Button onClick={handleTriggerPayout} disabled={isLoading} className="w-full">
            {isLoading ? 'Sending...' : 'Trigger Payout'}
          </Button>
        </CardContent>
      </Card>

      {message && (
        <Card
          className={
            message.type === 'error'
              ? 'border-red-200 bg-destructive/10'
              : 'border-green-200 bg-emerald-500/10'
          }
        >
          <CardContent className="pt-6">
            <div className="flex items-start space-x-2">
              {message.type === 'error' ? (
                <AlertCircle className="mt-0.5 h-5 w-5 flex-shrink-0 text-red-500" />
              ) : (
                <CheckCircle className="mt-0.5 h-5 w-5 flex-shrink-0 text-green-500" />
              )}
              <p
                className={`break-all text-sm font-medium ${
                  message.type === 'error' ? 'text-destructive' : 'text-emerald-400'
                }`}
              >
                {message.text}
              </p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
