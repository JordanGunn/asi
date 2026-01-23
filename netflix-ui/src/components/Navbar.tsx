'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 0);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled ? 'bg-[#141414]' : 'bg-gradient-to-b from-black/80 to-transparent'
      }`}
    >
      <div className="flex items-center justify-between px-4 md:px-12 py-4">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-[#e50914] font-bold text-2xl md:text-3xl tracking-wider">
            NETFLIX
          </Link>
          
          <ul className="hidden md:flex items-center gap-5 text-sm">
            <li><Link href="/" className="text-white hover:text-gray-300 transition">Home</Link></li>
            <li><Link href="/browse" className="text-gray-300 hover:text-white transition">TV Shows</Link></li>
            <li><Link href="/browse" className="text-gray-300 hover:text-white transition">Movies</Link></li>
            <li><Link href="/browse" className="text-gray-300 hover:text-white transition">New & Popular</Link></li>
            <li><Link href="/browse" className="text-gray-300 hover:text-white transition">My List</Link></li>
          </ul>
        </div>

        <div className="flex items-center gap-4">
          <button className="text-white hover:text-gray-300 transition">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </button>
          
          <button className="text-white hover:text-gray-300 transition">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
          </button>

          <div className="w-8 h-8 rounded bg-[#e50914] flex items-center justify-center cursor-pointer">
            <span className="text-white text-sm font-semibold">U</span>
          </div>

          <button 
            className="md:hidden text-white"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </div>
      </div>

      {isMobileMenuOpen && (
        <div className="md:hidden bg-[#141414] border-t border-gray-800">
          <ul className="flex flex-col py-4 px-4">
            <li><Link href="/" className="block py-2 text-white">Home</Link></li>
            <li><Link href="/browse" className="block py-2 text-gray-300">TV Shows</Link></li>
            <li><Link href="/browse" className="block py-2 text-gray-300">Movies</Link></li>
            <li><Link href="/browse" className="block py-2 text-gray-300">New & Popular</Link></li>
            <li><Link href="/browse" className="block py-2 text-gray-300">My List</Link></li>
          </ul>
        </div>
      )}
    </nav>
  );
}
