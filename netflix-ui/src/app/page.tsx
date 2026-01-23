'use client';

import { useState } from 'react';
import HeroBanner from '@/components/HeroBanner';
import ContentRow from '@/components/ContentRow';
import MovieModal from '@/components/MovieModal';
import { featuredMovies, categories, Movie } from '@/lib/data';

export default function Home() {
  const [selectedMovie, setSelectedMovie] = useState<Movie | null>(null);

  return (
    <div className="min-h-screen bg-[#141414]">
      <HeroBanner movies={featuredMovies} />
      
      <div className="-mt-32 relative z-10">
        {categories.map((category) => (
          <ContentRow
            key={category.id}
            title={category.title}
            movies={category.movies}
            onMovieClick={setSelectedMovie}
          />
        ))}
      </div>

      <MovieModal 
        movie={selectedMovie} 
        onClose={() => setSelectedMovie(null)} 
      />

      <footer className="py-12 px-4 md:px-12 text-gray-500 text-sm">
        <p>Netflix Clone - Demo purposes only</p>
      </footer>
    </div>
  );
}
