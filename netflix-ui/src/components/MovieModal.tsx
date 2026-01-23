'use client';

import { useEffect } from 'react';
import Image from 'next/image';
import { Movie } from '@/lib/data';

interface MovieModalProps {
  movie: Movie | null;
  onClose: () => void;
}

export default function MovieModal({ movie, onClose }: MovieModalProps) {
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  if (!movie) return null;

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80"
      onClick={onClose}
    >
      <div 
        className="relative w-full max-w-4xl max-h-[90vh] overflow-y-auto bg-[#181818] rounded-lg shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 w-9 h-9 rounded-full bg-[#181818] flex items-center justify-center hover:bg-[#252525] transition"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <div className="relative aspect-video">
          <Image
            src={movie.backdrop}
            alt={movie.title}
            fill
            className="object-cover rounded-t-lg"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#181818] via-transparent to-transparent" />
          
          <div className="absolute bottom-8 left-8 right-8">
            <h1 className="text-3xl md:text-5xl font-bold mb-4">{movie.title}</h1>
            <div className="flex gap-3">
              <button className="flex items-center gap-2 bg-white text-black px-8 py-2 rounded font-semibold hover:bg-gray-200 transition">
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z" />
                </svg>
                Play
              </button>
              <button className="w-10 h-10 rounded-full border-2 border-gray-400 flex items-center justify-center hover:border-white transition">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
              </button>
              <button className="w-10 h-10 rounded-full border-2 border-gray-400 flex items-center justify-center hover:border-white transition">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <div className="p-8">
          <div className="flex flex-col md:flex-row gap-8">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-4 text-sm">
                <span className="text-green-500 font-semibold">{movie.rating}% Match</span>
                <span>{movie.year}</span>
                <span className="border border-gray-400 px-1 text-xs">{movie.maturityRating}</span>
                <span>{movie.duration}</span>
              </div>
              <p className="text-gray-200 leading-relaxed">{movie.description}</p>
            </div>
            
            <div className="md:w-64 text-sm space-y-2">
              <p><span className="text-gray-400">Genres: </span>{movie.genres.join(', ')}</p>
              <p><span className="text-gray-400">This show is: </span>Suspenseful, Exciting</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
