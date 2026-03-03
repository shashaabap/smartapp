// app/(protected)/layout.tsx

'use client'

import { AuthProvider } from '@/lib/AuthContext'
import Sidebar from '@/components/layout/Sidebar'
import Breadcrumb from '@/components/layout/Breadcrumb'
import RouteGuard from '@/components/auth/RouteGuard'

export default function ProtectedLayout({ children }: any) {
  return (
    <AuthProvider>
      <div className="flex h-screen">
        <Sidebar />

        <main className="flex-1 p-6 bg-gray-100">
          <RouteGuard>
            <Breadcrumb />
            {children}
          </RouteGuard>
        </main>
      </div>
    </AuthProvider>
  )
}