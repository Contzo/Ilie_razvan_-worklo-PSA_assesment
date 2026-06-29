export const SALARY_DISTRIBUTOR_ABI = [
  // Constructor
  { type: 'constructor', inputs: [], stateMutability: 'nonpayable' },

  // Functions
  {
    type: 'function',
    name: 'distribute',
    inputs: [
      { name: '_recipients', type: 'address[]', internalType: 'address[]' },
      { name: '_amounts',    type: 'uint256[]', internalType: 'uint256[]' },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'setPayer',
    inputs: [{ name: '_newPayer', type: 'address', internalType: 'address' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'pause',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'unpause',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'getAuthorizedPayer',
    inputs: [{ name: '_payer', type: 'address', internalType: 'address' }],
    outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getPaused',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'owner',
    inputs: [],
    outputs: [{ name: '', type: 'address', internalType: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'transferOwnership',
    inputs: [{ name: 'newOwner', type: 'address', internalType: 'address' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'renounceOwnership',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },

  // Events
  {
    type: 'event',
    name: 'Distributed',
    inputs: [
      { name: 'recipient',     type: 'address', indexed: true,  internalType: 'address' },
      { name: 'amount',        type: 'uint256', indexed: false, internalType: 'uint256' },
    ],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'BatchCompleted',
    inputs: [
      { name: 'totalAmount',    type: 'uint256', indexed: false, internalType: 'uint256' },
      { name: 'recipientCount', type: 'uint256', indexed: false, internalType: 'uint256' },
    ],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'PayerAdded',
    inputs: [{ name: 'payer', type: 'address', indexed: true, internalType: 'address' }],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'PaymentPaused',
    inputs: [],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'PaymentUnpaused',
    inputs: [],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'OwnershipTransferred',
    inputs: [
      { name: 'previousOwner', type: 'address', indexed: true, internalType: 'address' },
      { name: 'newOwner',      type: 'address', indexed: true, internalType: 'address' },
    ],
    anonymous: false,
  },

  // Errors
  { type: 'error', name: 'SalaryDistributor__Paused',                    inputs: [] },
  { type: 'error', name: 'SalaryDistributor__UnauthorizedPayer',          inputs: [] },
  { type: 'error', name: 'SalaryDistributor__EmptyBatch',                 inputs: [] },
  { type: 'error', name: 'SalaryDistributor__InsufficientBalance',        inputs: [] },
  { type: 'error', name: 'SalaryDistributor__MissingRecipientsToAmounts', inputs: [] },
  { type: 'error', name: 'SalaryDistributor__ZeroAmount',                 inputs: [] },
  { type: 'error', name: 'SalaryDistributor__ZeroRecipientAddress',       inputs: [] },
  { type: 'error', name: 'SalaryDistributor__ZeroPayerAddress',           inputs: [] },
  {
    type: 'error',
    name: 'SalaryDistributor__TransferFailed',
    inputs: [
      { name: 'recipient', type: 'address', internalType: 'address' },
      { name: 'amount',    type: 'uint256', internalType: 'uint256' },
    ],
  },
  { type: 'error', name: 'OwnableInvalidOwner',       inputs: [{ name: 'owner',   type: 'address', internalType: 'address' }] },
  { type: 'error', name: 'OwnableUnauthorizedAccount', inputs: [{ name: 'account', type: 'address', internalType: 'address' }] },
];
