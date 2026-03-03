'use client'

import { useAuth } from '@/lib/AuthContext'
import { usePathname } from 'next/navigation'

export const usePermission = (controlCode: string) => {
  const auth = useAuth()
  const pathname = usePathname()

  if (!auth?.permissions?.[pathname]) return false

  return auth.permissions[pathname].includes(controlCode)
}