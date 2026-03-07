'use client'

import { usePathname } from 'next/navigation'
import { useAuth } from '@/lib/AuthContext'

export default function Breadcrumb() {
  const pathname = usePathname()
  const auth = useAuth()

  if (!auth?.menu) return null

  for (const module of auth.menu || []) {
    for (const sub of module.sub_modules || []) {
      for (const page of sub.pages || []) {
        if (page.route === pathname) {
          return (
            <div className="mb-4 text-sm text-gray-600">
              {module.module} → {sub.sub_module} → {page.page_name}
            </div>
          )
        }
      }
    }
  }

  return null
}