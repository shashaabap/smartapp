
'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { config } from '@/lib/config'
interface AuthState {
  client?: any
  user?: any
  role?: any
  location?: any
  menu?: any[]
  permissions?: Record<string, string[]>
  loading: boolean
  error?: string | null
}

const AuthContext = createContext<AuthState | null>(null)

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [authData, setAuthData] = useState<AuthState>({
    loading: true,
  })

  useEffect(() => {
    const loadBootstrap = async () => {
      try {
        const res = await fetch('/api/auth/bootstrap', {
            credentials: 'include',
          })

        if (!res.ok) {
          throw new Error('Failed to load bootstrap')
        }

        const data = await res.json()

        if (data?.error) {
          throw new Error(data.error)
        }

        setAuthData({
          ...data,
          loading: false,
          error: null,
        })
      } catch (err: any) {
        setAuthData({
          loading: false,
          error: err.message,
        })
      }
    }

    loadBootstrap()
  }, [])

  return (
    <AuthContext.Provider value={authData}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)

  if (!context) {
    throw new Error('useAuth must be used inside AuthProvider')
  }

  return context
}