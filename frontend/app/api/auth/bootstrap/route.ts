import { NextRequest, NextResponse } from 'next/server'

export async function GET(req: NextRequest) {
  const accessToken = req.cookies.get('access_token')?.value
console.log('TOKEN FROM COOKIE:', accessToken)
  if (!accessToken) {
    return NextResponse.json(
      { error: 'No token found' },
      { status: 401 }
    )
  }

  const res = await fetch('http://filatex.smartapp.com:4000/auth/bootstrap', {
    headers: {
      Cookie: `access_token=${accessToken}`,
    },
  })

  const data = await res.json()

  return NextResponse.json(data, { status: res.status })
}