'use client'

import { usePathname, useRouter } from 'next/navigation'
import { useEffect } from 'react'
import { useAuth } from '@/lib/AuthContext'

export default function RouteGuard({ children }: any) {
  const pathname = usePathname()
  const router = useRouter()
  const auth = useAuth()

  useEffect(() => {
    if (auth.loading) return

    if (auth.error) {
      router.replace('/login')
      return
    }

    const allowedRoutes = Object.keys(auth.permissions || {})

    if (!allowedRoutes.includes(pathname)) {
      router.replace('/dashboard')
    }
  }, [auth, pathname])

  if (auth.loading) return null

  return children
}