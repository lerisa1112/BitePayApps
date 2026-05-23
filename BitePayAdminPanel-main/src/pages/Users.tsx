import { useEffect, useState } from "react";

import {
  Search,
  Filter,
} from "lucide-react";

import axios from "axios";

export default function Users() {

  const [users, setUsers] =
    useState<any[]>([]);

  const [search, setSearch] =
    useState("");

  const [filter, setFilter] =
    useState<
      "All" | "Active" | "Inactive"
    >("All");

  const [loading, setLoading] =
    useState(true);

  // ==========================
  // FETCH USERS
  // ==========================

  useEffect(() => {

    fetchUsers();

  }, []);

  const fetchUsers = async () => {

    try {

      const token =
        localStorage.getItem("token");

      const res = await axios.get(

        "https://bitepay.onrender.com/api/admin/users",

        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }

      );

      console.log(res.data);

      setUsers(
        Array.isArray(res.data)
          ? res.data
          : []
      );

    } catch (error) {

      console.log("Users Fetch Error:", error);

    } finally {

      setLoading(false);

    }

  };

  // ==========================
  // SEARCH + FILTER
  // ==========================

  const filtered = users.filter((u) => {

    const matchSearch =
      u.name?.toLowerCase().includes(search.toLowerCase()) ||
      u.email?.toLowerCase().includes(search.toLowerCase());

    const status =
      u.isActiveCustomer
        ? "Active"
        : "Inactive";

    const matchFilter =
      filter === "All" ||
      status === filter;

    return matchSearch && matchFilter;

  });

  // ==========================
  // LOADING
  // ==========================

  if (loading) {

    return (
      <div className="p-10 text-xl font-bold">
        Loading Users...
      </div>
    );

  }

  return (

    <div className="p-6 space-y-5 bg-[#f8f8fc] min-h-screen">

      {/* STATS */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">

        {[

          {
            label: "Total Users",
            value: users.length,
            color: "#4f9cf9",
          },

          {
            label: "Active",
            value:
              users.filter(
                (u) => u.isActiveCustomer
              ).length,
            color: "#6ecf82",
          },

          {
            label: "Inactive",
            value:
              users.filter(
                (u) => !u.isActiveCustomer
              ).length,
            color: "#e05c7a",
          },

        ].map((s) => (

          <div
            key={s.label}
            className="rounded-2xl p-5 shadow-sm"
            style={{
              background: "white",
              border:
                "1px solid rgba(203,195,227,0.3)",
            }}
          >

            <p
              className="text-2xl font-bold"
              style={{
                color: s.color,
              }}
            >
              {s.value}
            </p>

            <p
              className="text-xs mt-1"
              style={{
                color: "#7c6f9f",
              }}
            >
              {s.label}
            </p>

          </div>

        ))}

      </div>

      {/* TABLE */}
      <div
        className="rounded-2xl shadow-sm overflow-hidden"
        style={{
          background: "white",
          border:
            "1px solid rgba(203,195,227,0.3)",
        }}
      >

        {/* TOP */}
        <div
          className="flex flex-wrap items-center justify-between gap-3 px-6 py-4"
          style={{
            borderBottom:
              "1px solid rgba(203,195,227,0.2)",
          }}
        >

          <h3 className="font-bold">
            All Users
          </h3>

          <div className="flex items-center gap-3">

            {/* FILTER */}
            <div className="flex gap-1 p-1 rounded-xl bg-gray-100">

              {["All", "Active", "Inactive"].map((f) => (

                <button
                  key={f}
                  onClick={() => setFilter(f as any)}
                  className="px-3 py-1 text-xs rounded-lg"
                  style={{
                    background:
                      filter === f
                        ? "white"
                        : "transparent",
                  }}
                >
                  {f}
                </button>

              ))}

            </div>

            {/* SEARCH */}
            <div className="relative">

              <Search className="absolute left-2 top-2 w-4 h-4" />

              <input
                value={search}
                onChange={(e) =>
                  setSearch(e.target.value)
                }
                placeholder="Search users..."
                className="pl-7 pr-2 py-2 text-xs border rounded-lg"
              />

            </div>

            <Filter className="w-4 h-4" />

          </div>

        </div>

        {/* TABLE */}
        <div className="overflow-x-auto">

          <table className="w-full text-sm">

            <thead>

              <tr className="bg-gray-50">

                {["#", "Name", "Email", "Role", "Phone", "Status"].map((h) => (

                  <th key={h} className="text-left px-6 py-3 text-xs">
                    {h}
                  </th>

                ))}

              </tr>

            </thead>

            <tbody>

              {filtered.map((user, i) => (

                <tr key={user._id} className="border-t">

                  <td className="px-6 py-3">
                    {i + 1}
                  </td>

                  <td className="px-6 py-3">
                    {user.name}
                  </td>

                  <td className="px-6 py-3">
                    {user.email}
                  </td>

                  <td className="px-6 py-3">
                    {user.role}
                  </td>

                  <td className="px-6 py-3">
                    {user.phone || "N/A"}
                  </td>

                  <td className="px-6 py-3">

                    <span
                      className="px-2 py-1 text-xs rounded-full"
                      style={{
                        background: user.isActiveCustomer
                          ? "#d1fae5"
                          : "#fee2e2",
                        color: user.isActiveCustomer
                          ? "#166534"
                          : "#991b1b",
                      }}
                    >
                      {user.isActiveCustomer
                        ? "Active"
                        : "Inactive"}
                    </span>

                  </td>

                </tr>

              ))}

            </tbody>

          </table>

        </div>

      </div>

    </div>

  );

}