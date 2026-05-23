export type Page = 'dashboard' | 'users' | 'vendors' | 'orders' | 'wallet';

export interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  status: 'Active' | 'Inactive';
  joined: string;
}

export interface Vendor {
  id: number;
  name: string;
  business: string;
  email: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  date: string;
}

export interface Order {
  id: string;
  customer: string;
  product: string;
  amount: number;
  status: 'Delivered' | 'Pending' | 'Cancelled';
  date: string;
}

export interface WalletTransaction {
  id: number;
  user: string;
  type: 'Credit' | 'Debit';
  amount: number;
  description: string;
  date: string;
}
