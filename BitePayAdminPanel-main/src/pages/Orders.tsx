import { useEffect, useState } from "react";
import axios from "axios";
import {
  Search,
  Package,
  Truck,
  CheckCircle,
  XCircle,
} from "lucide-react";

const statusStyle: any = {
  Delivered: {
    bg: "rgba(110,207,130,0.15)",
    color: "#3d9e54",
    icon: CheckCircle,
  },
  Pending: {
    bg: "rgba(249,167,79,0.15)",
    color: "#c4760a",
    icon: Truck,
  },
  Cancelled: {
    bg: "rgba(224,92,122,0.15)",
    color: "#b53b5f",
    icon: XCircle,
  },
  Placed: {
    bg: "rgba(249,167,79,0.15)",
    color: "#c4760a",
    icon: Truck,
  },
  Preparing: {
    bg: "rgba(249,167,79,0.15)",
    color: "#c4760a",
    icon: Truck,
  },
};

export default function Orders() {
  const [orders, setOrders] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const token = localStorage.getItem("token");

      const res = await axios.get(
        "https://bitepay.onrender.com/api/admin/orders",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      setOrders(Array.isArray(res.data) ? res.data : []);
    } catch (err) {
      console.log(err);
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  // SEARCH SAFE
  const filtered = orders.filter((o) => {
    const q = search.toLowerCase();

    const customer = o.user?.name || "guest";
    const product = o.items?.[0]?.name || o.items?.[0]?.foodName || "";
    const orderId = o._id || "";

    return (
      customer.toLowerCase().includes(q) ||
      product.toLowerCase().includes(q) ||
      orderId.toLowerCase().includes(q)
    );
  });

  const totalRevenue = orders.reduce(
    (sum, o) => sum + (o.totalAmount || 0),
    0
  );

  if (loading) {
    return <div className="p-10 font-bold">Loading Orders...</div>;
  }

  return (
    <div className="p-6 space-y-5 bg-gray-50 min-h-screen">

      {/* HEADER */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Orders</h1>

        <div className="relative">
          <Search className="absolute left-3 top-2.5 w-4 h-4 text-gray-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search orders..."
            className="pl-9 pr-3 py-2 border rounded-lg text-sm"
          />
        </div>
      </div>

      {/* STATS */}
      <div className="grid grid-cols-4 gap-4">
        <Stat label="Total Orders" value={orders.length} />
        <Stat
          label="Pending"
          value={orders.filter((o) => o.orderStatus === "Pending").length}
        />
        <Stat
          label="Delivered"
          value={orders.filter((o) => o.orderStatus === "Delivered").length}
        />
        <Stat label="Revenue" value={`₹${totalRevenue}`} />
      </div>

      {/* TABLE */}
      <div className="bg-white shadow rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-100 text-left">
            <tr>
              <th className="p-3">Order ID</th>
              <th>Customer</th>
              <th>Product</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>

          <tbody>
            {filtered.map((o) => {
              const status = o.orderStatus || o.status || "Pending";
              const S = statusStyle[status] || statusStyle.Pending;
              const Icon = S.icon;

              const product =
                o.items?.[0]?.name || o.items?.[0]?.foodName || "Item";

              const customer = o.user?.name || "Guest";

              return (
                <tr key={o._id} className="border-t">
                  <td className="p-3 font-mono text-xs">
                    {o._id?.slice(0, 8)}
                  </td>

                  <td>{customer}</td>

                  <td>{product}</td>

                  <td>₹{o.totalAmount}</td>

                  <td>
                    <span
                      className="flex items-center gap-1 px-2 py-1 rounded text-xs w-fit"
                      style={{
                        background: S.bg,
                        color: S.color,
                      }}
                    >
                      <Icon className="w-3 h-3" />
                      {status}
                    </span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {filtered.length === 0 && (
          <div className="p-6 text-center text-gray-400">
            No orders found
          </div>
        )}
      </div>
    </div>
  );
}

/* STAT CARD */
function Stat({ label, value }: any) {
  return (
    <div className="bg-white p-4 rounded-lg shadow">
      <p className="text-xl font-bold">{value}</p>
      <p className="text-sm text-gray-500">{label}</p>
    </div>
  );
}