'use client';

import { useState, useEffect } from 'react';
import { Movie } from '@/lib/data';

interface HeroBannerProps {
  movies: Movie[];
}

export default function HeroBanner({ movies }: HeroBannerProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const featured = movies[currentIndex];

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % movies.length);
    }, 8000);
    return () => clearInterval(interval);
  }, [movies.length]);

  if (!featured) return null;

  return (
    <div className="relative h-[80vh] md:h-[90vh] w-full">
      <div 
        className="absolute inset-0 bg-cover bg-center transition-all duration-1000"
        style={{ backgroundImage: `url(${featured.backdrop})` }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-[#141414] via-transparent to-transparent" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#141414] via-transparent to-transparent" />
      </div>

      <div className="relative z-10 flex flex-col justify-end h-full pb-32 px-4 md:px-12">
        <div className="max-w-2xl">
          <h1 className="text-4xl md:text-6xl font-bold mb-4 drop-shadow-lg">
            {featured.title}
          </h1>
          
          <div className="flex items-center gap-3 mb-4 text-sm">
            <span className="text-green-500 font-semibold">{featured.rating}% Match</span>
            <span className="border border-gray-400 px-1 text-xs">{featured.maturityRating}</span>
            <span>{featured.year}</span>
            <span>{featured.duration}</span>
          </div>

          <p className="text-base md:text-lg text-gray-200 mb-6 line-clamp-3 drop-shadow">
            {featured.description}
          </p>

          <div className="flex gap-3">
            <button className="flex items-center gap-2 bg-white text-black px-6 py-2 rounded font-semibold hover:bg-gray-200 transition">
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z" />
              </svg>
              Play
            </button>
            <button className="flex items-center gap-2 bg-gray-500/70 text-white px-6 py-2 rounded font-semibold hover:bg-gray-500/50 transition">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              More Info
            </button>
          </div>
        </div>

        <div className="absolute bottom-8 right-8 flex gap-2">
          {movies.slice(0, 5).map((_, i) => (
            <button
              key={i}
              onClick={() => setCurrentIndex(i)}
              className={`w-3 h-3 rounded-full transition ${
                i === currentIndex ? 'bg-white' : 'bg-gray-500 hover:bg-gray-400'
              }`}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
