import { useEffect, useState } from "react";
import axios from "axios";
import { CheckCircle, XCircle, Clock, Search } from "lucide-react";

export default function Vendors() {
  const [vendors, setVendors] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("pending"); // 👈 NEW

  useEffect(() => {
    fetchVendors();
  }, [activeTab]);

  //
  // FETCH (PENDING / APPROVED SWITCH)
  //
  const fetchVendors = async () => {
    try {
      const token = localStorage.getItem("token");

      const url =
        activeTab === "approved"
          ? "https://bitepay.onrender.com/api/admin/vendors/approved"
          : "https://bitepay.onrender.com/api/admin/vendors/pending";

      const res = await axios.get(url, {
        headers: { Authorization: `Bearer ${token}` },
      });

      setVendors(Array.isArray(res.data) ? res.data : []);
    } catch (err) {
      console.log(err);
      setVendors([]);
    } finally {
      setLoading(false);
    }
  };

  //
  // APPROVE
  //
 const approveVendor = async (id: string) => {
  try {
    const token = localStorage.getItem("token");

    await axios.put(
      `https://bitepay.onrender.com/api/admin/vendor/approve/${id}`,
      {},
      { headers: { Authorization: `Bearer ${token}` } }
    );

    // ✅ LIVE UPDATE (NO REMOVE)
    setVendors((prev) =>
      prev.map((v) =>
        v._id === id
          ? { ...v, isApproved: true, vendorStatus: "Approved" }
          : v
      )
    );
  } catch (err) {
    console.log(err);
  }
};

  //
  // REJECT
  //
  const rejectVendor = async (id: string) => {
  try {
    const token = localStorage.getItem("token");

    await axios.put(
      `https://bitepay.onrender.com/api/admin/vendor/reject/${id}`,
      {},
      { headers: { Authorization: `Bearer ${token}` } }
    );

    // ✅ LIVE UPDATE (NO REMOVE)
    setVendors((prev) =>
      prev.map((v) =>
        v._id === id
          ? { ...v, isApproved: false, vendorStatus: "Rejected" }
          : v
      )
    );
  } catch (err) {
    console.log(err);
  }
};

  //
  // SEARCH FILTER
  //
  const filtered = Array.isArray(vendors)
    ? vendors.filter((v) => {
        const q = search.toLowerCase();

        return (
          v?.name?.toLowerCase().includes(q) ||
          v?.email?.toLowerCase().includes(q) ||
          v?.canteenName?.toLowerCase().includes(q)
        );
      })
    : [];

  const statusStyle: any = {
    Approved: { color: "green", icon: CheckCircle },
    "Pending Review": { color: "orange", icon: Clock },
    Rejected: { color: "red", icon: XCircle },
  };

  if (loading) {
    return (
      <div className="p-10 text-lg font-semibold">
        Loading vendors...
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 bg-gray-50 min-h-screen">

      {/* HEADER */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Vendor Management</h1>

        <div className="flex gap-2">
          {/* TAB BUTTONS */}
          <button
            onClick={() => {
              setLoading(true);
              setActiveTab("pending");
            }}
            className={`px-3 py-1 rounded text-sm ${
              activeTab === "pending"
                ? "bg-orange-500 text-white"
                : "bg-gray-200"
            }`}
          >
            Pending
          </button>

          <button
            onClick={() => {
              setLoading(true);
              setActiveTab("approved");
            }}
            className={`px-3 py-1 rounded text-sm ${
              activeTab === "approved"
                ? "bg-green-500 text-white"
                : "bg-gray-200"
            }`}
          >
            Approved
          </button>
        </div>
      </div>

      {/* SEARCH */}
      <div className="relative w-64">
        <Search className="absolute left-3 top-2.5 w-4 h-4 text-gray-400" />
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search vendors..."
          className="pl-9 pr-3 py-2 border rounded-lg text-sm w-full"
        />
      </div>

      {/* TABLE */}
      <div className="bg-white shadow rounded-lg overflow-hidden">

        <table className="w-full text-sm">
          <thead className="bg-gray-100 text-left">
            <tr>
              <th className="p-3">Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>

          <tbody>
            {filtered.map((v) => {
              const status =
                v?.vendorStatus || "Pending Review";

              const S =
                statusStyle[status] ||
                statusStyle["Pending Review"];

              const Icon = S.icon;

              return (
                <tr key={v._id} className="border-t">
                  <td className="p-3 font-medium">{v?.name}</td>
                  <td>{v?.email}</td>
                  <td>{v?.phone}</td>

                  {/* STATUS */}
                  <td>
                    <span
                      className="flex items-center gap-1 text-xs px-2 py-1 rounded w-fit"
                      style={{ color: S.color }}
                    >
                      <Icon className="w-3 h-3" />
                      {status}
                    </span>
                  </td>

                  {/* ACTION */}
                  <td className="space-x-2">
                    {activeTab === "pending" ? (
                      <>
                        <button
                          onClick={() => approveVendor(v._id)}
                          className="px-3 py-1 bg-green-100 text-green-700 rounded text-xs"
                        >
                          Approve
                        </button>

                        <button
                          onClick={() => rejectVendor(v._id)}
                          className="px-3 py-1 bg-red-100 text-red-700 rounded text-xs"
                        >
                          Reject
                        </button>
                      </>
                    ) : (
                      <span className="text-xs text-gray-400">
                        Completed
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {filtered.length === 0 && (
          <div className="p-6 text-center text-gray-400">
            No vendors found
          </div>
        )}
      </div>
    </div>
  );
}