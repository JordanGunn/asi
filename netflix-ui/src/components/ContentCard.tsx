'use client';

import { useState } from 'react';
import Image from 'next/image';
import { Movie } from '@/lib/data';

interface ContentCardProps {
  movie: Movie;
  onClick?: () => void;
}

export default function ContentCard({ movie, onClick }: ContentCardProps) {
  const [isHovered, setIsHovered] = useState(false);
  const [imageError, setImageError] = useState(false);

  return (
    <div
      className="relative flex-shrink-0 w-[160px] md:w-[200px] cursor-pointer group"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={onClick}
    >
      <div className={`relative aspect-[2/3] rounded overflow-hidden transition-all duration-300 ${
        isHovered ? 'scale-110 z-30 shadow-2xl' : 'scale-100'
      }`}>
        {!imageError ? (
          <Image
            src={movie.poster}
            alt={movie.title}
            fill
            className="object-cover"
            onError={() => setImageError(true)}
          />
        ) : (
          <div className="w-full h-full bg-gray-800 flex items-center justify-center">
            <span className="text-gray-400 text-xs text-center px-2">{movie.title}</span>
          </div>
        )}
        
        {isHovered && (
          <div className="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-100">
            <div className="absolute bottom-0 left-0 right-0 p-3">
              <h3 className="text-sm font-semibold mb-1 line-clamp-1">{movie.title}</h3>
              
              <div className="flex items-center gap-2 mb-2">
                <button className="w-7 h-7 rounded-full bg-white flex items-center justify-center hover:bg-gray-200 transition">
                  <svg className="w-4 h-4 text-black" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                </button>
                <button className="w-7 h-7 rounded-full border-2 border-gray-400 flex items-center justify-center hover:border-white transition">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                </button>
                <button className="w-7 h-7 rounded-full border-2 border-gray-400 flex items-center justify-center hover:border-white transition">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
                  </svg>
                </button>
                <button className="w-7 h-7 rounded-full border-2 border-gray-400 flex items-center justify-center hover:border-white transition ml-auto">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
              </div>

              <div className="flex items-center gap-2 text-xs">
                <span className="text-green-500 font-semibold">{movie.rating}%</span>
                <span className="border border-gray-500 px-1">{movie.maturityRating}</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
