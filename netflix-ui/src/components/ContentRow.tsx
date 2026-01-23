'use client';

import { useRef, useState } from 'react';
import { Movie } from '@/lib/data';
import ContentCard from './ContentCard';

interface ContentRowProps {
  title: string;
  movies: Movie[];
  onMovieClick?: (movie: Movie) => void;
}

export default function ContentRow({ title, movies, onMovieClick }: ContentRowProps) {
  const rowRef = useRef<HTMLDivElement>(null);
  const [showLeftArrow, setShowLeftArrow] = useState(false);
  const [showRightArrow, setShowRightArrow] = useState(true);

  const scroll = (direction: 'left' | 'right') => {
    if (!rowRef.current) return;
    
    const scrollAmount = rowRef.current.clientWidth * 0.8;
    const newScrollLeft = direction === 'left' 
      ? rowRef.current.scrollLeft - scrollAmount
      : rowRef.current.scrollLeft + scrollAmount;
    
    rowRef.current.scrollTo({ left: newScrollLeft, behavior: 'smooth' });
  };

  const handleScroll = () => {
    if (!rowRef.current) return;
    setShowLeftArrow(rowRef.current.scrollLeft > 0);
    setShowRightArrow(
      rowRef.current.scrollLeft < rowRef.current.scrollWidth - rowRef.current.clientWidth - 10
    );
  };

  return (
    <div className="mb-8 group/row">
      <h2 className="text-lg md:text-xl font-semibold mb-2 px-4 md:px-12">
        {title}
      </h2>
      
      <div className="relative">
        {showLeftArrow && (
          <button
            onClick={() => scroll('left')}
            className="absolute left-0 top-0 bottom-0 z-20 w-12 bg-black/50 opacity-0 group-hover/row:opacity-100 transition flex items-center justify-center hover:bg-black/70"
          >
            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
        )}

        <div
          ref={rowRef}
          onScroll={handleScroll}
          className="flex gap-2 overflow-x-scroll scrollbar-hide px-4 md:px-12 pb-4"
          style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
        >
          {movies.map((movie) => (
            <ContentCard 
              key={movie.id} 
              movie={movie} 
              onClick={() => onMovieClick?.(movie)}
            />
          ))}
        </div>

        {showRightArrow && (
          <button
            onClick={() => scroll('right')}
            className="absolute right-0 top-0 bottom-0 z-20 w-12 bg-black/50 opacity-0 group-hover/row:opacity-100 transition flex items-center justify-center hover:bg-black/70"
          >
            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
            </svg>
          </button>
        )}
      </div>
    </div>
  );
}
