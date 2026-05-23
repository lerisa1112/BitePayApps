import {
  ArrowDownCircle,
  ArrowUpCircle,
  Wallet as WalletIcon,
  TrendingUp,
} from "lucide-react";

import axios from "axios";
import { useEffect, useState, useMemo } from "react";

export default function Wallet() {
  const [wallets, setWallets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  //
  // FETCH WALLET DATA
  //
  useEffect(() => {
    fetchWallets();
  }, []);

  const fetchWallets = async () => {
    try {
      const token = localStorage.getItem("token");

      const res = await axios.get(
        "https://bitepay.onrender.com/api/admin/wallets",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      setWallets(Array.isArray(res.data) ? res.data : []);
    } catch (error) {
      console.log(error);
      setWallets([]);
    } finally {
      setLoading(false);
    }
  };

  //
  // FLATTEN ALL TRANSACTIONS
  //
  const allTransactions = useMemo(() => {
    const txs: any[] = [];

    wallets.forEach((w) => {
      (w.transactions || []).forEach((t: any) => {
        txs.push({
          ...t,
          user: w.user,
        });
      });
    });

    return txs.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() -
        new Date(a.createdAt).getTime()
    );
  }, [wallets]);

  //
  // TOTAL CREDIT / DEBIT
  //
  const totalCredit = allTransactions
    .filter((t) => t.type?.toLowerCase() === "credit")
    .reduce((sum, t) => sum + (t.amount || 0), 0);

  const totalDebit = allTransactions
    .filter((t) => t.type?.toLowerCase() === "debit")
    .reduce((sum, t) => sum + (t.amount || 0), 0);

  const balance = totalCredit - totalDebit;

  //
  // LOADING
  //
  if (loading) {
    return (
      <div className="p-10 text-xl font-bold">
        Loading Wallet Data...
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">

      {/* BALANCE CARD */}
      <div
        className="rounded-2xl p-6 shadow-md"
        style={{
          background:
            "linear-gradient(135deg, #1a1a2e 0%, #2d2053 100%)",
        }}
      >
        <div className="flex items-center gap-2 mb-4">
          <WalletIcon className="w-5 h-5 text-white" />
          <span className="text-sm text-gray-300">
            Total Wallet Balance
          </span>
        </div>

        <p className="text-4xl font-bold text-white">
          ₹{balance.toLocaleString()}
        </p>

        <div className="flex items-center gap-1 mt-2 text-green-400 text-xs">
          <TrendingUp className="w-3 h-3" />
          Wallet Overview
        </div>
      </div>

      {/* CREDIT / DEBIT */}
      <div className="grid grid-cols-2 gap-4">

        {/* CREDIT */}
        <div className="p-5 bg-white rounded-2xl shadow-sm">
          <p className="text-xs text-gray-500">Total Credits</p>
          <p className="text-xl font-bold text-green-600">
            ₹{totalCredit.toLocaleString()}
          </p>
        </div>

        {/* DEBIT */}
        <div className="p-5 bg-white rounded-2xl shadow-sm">
          <p className="text-xs text-gray-500">Total Debits</p>
          <p className="text-xl font-bold text-red-500">
            ₹{totalDebit.toLocaleString()}
          </p>
        </div>

      </div>

      {/* TABLE */}
      <div className="bg-white rounded-2xl shadow-sm overflow-hidden">

        <div className="p-4 border-b">
          <h3 className="font-bold">Transaction History</h3>
        </div>

        <table className="w-full text-sm">

          <thead className="bg-gray-100">
            <tr>
              <th className="p-3 text-left">User</th>
              <th className="text-left">Type</th>
              <th className="text-left">Amount</th>
              <th className="text-left">Note</th>
              <th className="text-left">Date</th>
            </tr>
          </thead>

          <tbody>

            {allTransactions.map((tx) => {
              const isCredit =
                tx.type?.toLowerCase() === "credit";

              return (
                <tr key={tx._id} className="border-t">

                  {/* USER */}
                  <td className="p-3">
                    {tx.user?.name || "Unknown"}
                  </td>

                  {/* TYPE */}
                  <td>
                    <span
                      className="flex items-center gap-1 text-xs px-2 py-1 rounded"
                      style={{
                        color: isCredit ? "green" : "red",
                      }}
                    >
                      {isCredit ? (
                        <ArrowDownCircle className="w-3 h-3" />
                      ) : (
                        <ArrowUpCircle className="w-3 h-3" />
                      )}

                      {tx.type}
                    </span>
                  </td>

                  {/* AMOUNT */}
                  <td
                    className="font-semibold"
                    style={{
                      color: isCredit ? "green" : "red",
                    }}
                  >
                    {isCredit ? "+" : "-"}₹{tx.amount}
                  </td>

                  {/* NOTE */}
                  <td>{tx.note || "-"}</td>

                  {/* DATE */}
                  <td>
                    {tx.createdAt
                      ? new Date(tx.createdAt).toLocaleDateString()
                      : "-"}
                  </td>

                </tr>
              );
            })}

          </tbody>

        </table>

        {allTransactions.length === 0 && (
          <div className="p-10 text-center text-gray-400">
            No wallet transactions found
          </div>
        )}

      </div>
    </div>
  );
}