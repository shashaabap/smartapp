'use client'

import { useState } from 'react'
import { useAuth } from '@/lib/AuthContext'
import { usePathname } from 'next/navigation'
import Link from 'next/link'

export default function Sidebar() {
  const [collapsed, setCollapsed] = useState(false)
  const auth = useAuth()
  const pathname = usePathname()
//console.log('AUTH DATA:', auth)
  // ✅ 1️⃣ Handle loading FIRST
  if (auth.loading) {
    return (
      <aside className="w-64 bg-gray-900 text-white" />
    )
  }

  // ✅ 2️⃣ If no menu after loading (error case)
  if (!auth?.menu) return null

  return (
    <aside
      className={`bg-gray-900 text-white transition-all duration-300 ${
        collapsed ? 'w-20' : 'w-64'
      }`}
    >
      <div className="flex justify-between items-center p-4 border-b border-gray-700">
        {!collapsed && <span className="font-bold">{auth.client?.name}</span>}
        <button onClick={() => setCollapsed(!collapsed)}>☰</button>
      </div>

      <nav className="p-4 space-y-3">
        {auth.menu.map((module: any, i: number) => (
          <div key={i}>
            {!collapsed && (
              <p className="text-xs uppercase text-gray-400">
                {module.module}
              </p>
            )}

            {module.sub_modules?.map((sub: any, j: number) =>
              sub.pages?.map((page: any, k: number) => (
                <Link
                  key={k}
                  href={page.route}
                  className={`block px-3 py-2 rounded-md text-sm ${
                    pathname === page.route
                      ? 'bg-blue-600'
                      : 'hover:bg-gray-700'
                  }`}
                >
                  {collapsed ? '•' : page.page_name}
                </Link>
              ))
            )}
          </div>
        ))}
      </nav>
    </aside>
  )
  
}