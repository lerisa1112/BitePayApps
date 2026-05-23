import {
  Users,
  Store,
  ShoppingCart,
  DollarSign,
  Package,
} from "lucide-react";

import { useEffect, useState } from "react";
import axios from "axios";

const statusStyle: Record<
  string,
  { bg: string; color: string }
> = {
  Delivered: {
    bg: "rgba(110,207,130,0.15)",
    color: "#3d9e54",
  },

  Pending: {
    bg: "rgba(249,167,79,0.15)",
    color: "#c4760a",
  },

  Cancelled: {
    bg: "rgba(224,92,122,0.15)",
    color: "#b53b5f",
  },

  Placed: {
    bg: "rgba(79,156,249,0.15)",
    color: "#4f9cf9",
  },

  Preparing: {
    bg: "rgba(203,195,227,0.25)",
    color: "#7c6f9f",
  },

  Ready: {
    bg: "rgba(110,207,130,0.15)",
    color: "#3d9e54",
  },

  Completed: {
    bg: "rgba(110,207,130,0.15)",
    color: "#3d9e54",
  },
};

export default function Dashboard() {
  const [dashboard, setDashboard] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      const token = localStorage.getItem("token");

      const res = await axios.get(
        "https://bitepay.onrender.com/api/admin/dashboard",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      console.log(res.data);

      setDashboard(res.data);
    } catch (error) {
      console.log("Dashboard Error:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="p-10 text-xl font-bold">
        Loading Dashboard...
      </div>
    );
  }

  if (!dashboard) {
    return (
      <div className="p-10 text-red-500 font-bold">
        Failed to load dashboard
      </div>
    );
  }

  const stats = [
    {
      label: "Total Users",
      value: dashboard.totalUsers || 0,
      icon: Users,
      color: "#4f9cf9",
    },

    {
      label: "Active Vendors",
      value: dashboard.activeVendors || 0,
      icon: Store,
      color: "#6ecf82",
    },

    {
      label: "Total Orders",
      value: dashboard.totalOrders || 0,
      icon: ShoppingCart,
      color: "#f9a74f",
    },

    {
      label: "Revenue",
      value: `₹${dashboard.totalRevenue || 0}`,
      icon: DollarSign,
      color: "#e05c7a",
    },
  ];

  return (
    <div className="p-6 space-y-6 bg-[#f8f8fc] min-h-screen">
      {/* TOP STATS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
        {stats.map((stat) => {
          const Icon = stat.icon;

          return (
            <div
              key={stat.label}
              className="rounded-2xl p-5 shadow-sm"
              style={{
                background: "white",
                border:
                  "1px solid rgba(203,195,227,0.3)",
              }}
            >
              <div className="flex items-center justify-between mb-4">
                <div
                  className="w-11 h-11 rounded-xl flex items-center justify-center"
                  style={{
                    background: `${stat.color}18`,
                  }}
                >
                  <Icon
                    className="w-5 h-5"
                    style={{
                      color: stat.color,
                    }}
                  />
                </div>
              </div>

              <p
                className="text-2xl font-bold"
                style={{
                  color: "#1a1a2e",
                }}
              >
                {stat.value}
              </p>

              <p
                className="text-xs mt-1"
                style={{
                  color: "#7c6f9f",
                }}
              >
                {stat.label}
              </p>
            </div>
          );
        })}
      </div>

      {/* QUICK STATS */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        {/* QUICK INFO */}
        <div
          className="rounded-2xl p-6 shadow-sm"
          style={{
            background: "white",
            border:
              "1px solid rgba(203,195,227,0.3)",
          }}
        >
          <h3 className="font-bold text-base mb-5">
            Quick Stats
          </h3>

          <div className="space-y-5">
            {[
              {
                label: "New Users Today",
                value:
                  dashboard.newUsersToday || 0,
                max: 100,
                color: "#4f9cf9",
              },

              {
                label: "Orders Today",
                value: dashboard.ordersToday || 0,
                max: 100,
                color: "#cbc3e3",
              },

              {
                label: "Pending Vendors",
                value:
                  dashboard.pendingVendors || 0,
                max: 100,
                color: "#f9a74f",
              },

              {
                label: "Wallet Balance",
                value:
                  dashboard.walletBalance || 0,
                max: 1000,
                color: "#6ecf82",
              },
            ].map((item) => (
              <div key={item.label}>
                <div className="flex justify-between text-xs mb-2">
                  <span>{item.label}</span>

                  <span className="font-semibold">
                    {item.label ===
                    "Wallet Balance"
                      ? `₹${item.value}`
                      : item.value}
                  </span>
                </div>

                <div className="h-2 rounded-full bg-gray-200 overflow-hidden">
                  <div
                    className="h-full rounded-full"
                    style={{
                      width: `${
                        (item.value / item.max) * 100
                      }%`,
                      background: item.color,
                    }}
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="mt-6 p-4 rounded-xl bg-gray-50">
            <div className="flex items-center gap-3">
              <Package className="w-5 h-5 text-purple-500" />

              <div>
                <p className="text-xs font-semibold">
                  System Status
                </p>

                <p className="text-xs text-gray-500">
                  All services running
                </p>
              </div>

              <div className="ml-auto w-2 h-2 rounded-full bg-green-500 animate-pulse" />
            </div>
          </div>
        </div>

        {/* RECENT ACTIVITY */}
        <div
          className="rounded-2xl p-6 shadow-sm"
          style={{
            background: "white",
            border:
              "1px solid rgba(203,195,227,0.3)",
          }}
        >
          <h3 className="font-bold text-base mb-5">
            Recent Activity
          </h3>

          <div className="space-y-4">
            {dashboard.recentOrders
              ?.slice(0, 5)
              .map((order: any) => (
                <div
                  key={order._id}
                  className="flex items-center justify-between border-b pb-3"
                >
                  <div>
                    <p className="font-semibold text-sm">
                      {order.user?.name}
                    </p>

                    <p className="text-xs text-gray-500">
                      {order.items?.[0]?.name}
                    </p>
                  </div>

                  <div className="text-right">
                    <p className="font-semibold text-sm">
                      ₹{order.totalAmount}
                    </p>

                    <span
                      className="px-2 py-1 rounded-full text-xs"
                      style={
                        statusStyle[
                          order.status
                        ] || {
                          background: "#eee",
                          color: "#333",
                        }
                      }
                    >
                      {order.status}
                    </span>
                  </div>
                </div>
              ))}
          </div>
        </div>
      </div>

      {/* RECENT ORDERS */}
      <div
        className="rounded-2xl shadow-sm overflow-hidden"
        style={{
          background: "white",
          border: "1px solid rgba(203,195,227,0.3)",
        }}
      >
        <div className="px-6 py-4 border-b">
          <h3 className="font-bold text-base">
            Recent Orders
          </h3>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50">
                <th className="text-left px-6 py-3">
                  Order ID
                </th>

                <th className="text-left px-6 py-3">
                  Customer
                </th>

                <th className="text-left px-6 py-3">
                  Product
                </th>

                <th className="text-left px-6 py-3">
                  Amount
                </th>

                <th className="text-left px-6 py-3">
                  Status
                </th>
              </tr>
            </thead>

            <tbody>
              {dashboard.recentOrders?.map(
                (order: any, i: number) => (
                  <tr
                    key={order._id}
                    className={
                      i > 0 ? "border-t" : ""
                    }
                  >
                    <td className="px-6 py-4 font-mono text-xs">
                      {order._id.slice(-6)}
                    </td>

                    <td className="px-6 py-4">
                      {order.user?.name}
                    </td>

                    <td className="px-6 py-4">
                      {order.items?.[0]?.name}
                    </td>

                    <td className="px-6 py-4 font-semibold">
                      ₹{order.totalAmount}
                    </td>

                    <td className="px-6 py-4">
                      <span
                        className="px-2 py-1 rounded-full text-xs"
                        style={
                          statusStyle[
                            order.status
                          ] || {
                            background: "#eee",
                            color: "#333",
                          }
                        }
                      >
                        {order.status}
                      </span>
                    </td>
                  </tr>
                )
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}