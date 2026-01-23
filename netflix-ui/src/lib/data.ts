export interface Movie {
  id: number;
  title: string;
  description: string;
  backdrop: string;
  poster: string;
  rating: number;
  maturityRating: string;
  year: number;
  duration: string;
  genres: string[];
}

export interface Category {
  id: string;
  title: string;
  movies: Movie[];
}

const generateMovies = (count: number, offset: number = 0): Movie[] => {
  const titles = [
    "Stranger Things", "The Crown", "Wednesday", "Squid Game", "Money Heist",
    "Bridgerton", "Ozark", "The Witcher", "Cobra Kai", "You",
    "Dark", "Narcos", "Peaky Blinders", "Breaking Bad", "Better Call Saul",
    "The Last Kingdom", "Vikings", "Black Mirror", "Mindhunter", "The Umbrella Academy"
  ];
  
  const descriptions = [
    "When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.",
    "This drama follows the political rivalries and romance of Queen Elizabeth II's reign and the events that shaped the second half of the 20th century.",
    "Smart, sarcastic and a little dead inside, Wednesday Addams investigates a murder spree while making new friends — and foes — at Nevermore Academy.",
    "Hundreds of cash-strapped players accept a strange invitation to compete in children's games. Inside, a tempting prize awaits with deadly high stakes.",
    "Eight thieves take hostages and lock themselves in the Royal Mint of Spain as a criminal mastermind manipulates the police to carry out his plan.",
  ];

  return Array.from({ length: count }, (_, i) => ({
    id: offset + i + 1,
    title: titles[(offset + i) % titles.length],
    description: descriptions[(offset + i) % descriptions.length],
    backdrop: `https://picsum.photos/seed/${offset + i + 100}/1920/1080`,
    poster: `https://picsum.photos/seed/${offset + i + 200}/300/450`,
    rating: Math.floor(Math.random() * 30) + 70,
    maturityRating: ['TV-MA', 'TV-14', 'PG-13', 'R'][Math.floor(Math.random() * 4)],
    year: 2020 + Math.floor(Math.random() * 5),
    duration: `${Math.floor(Math.random() * 3) + 1}h ${Math.floor(Math.random() * 59)}m`,
    genres: ['Drama', 'Thriller', 'Sci-Fi', 'Action', 'Comedy'].slice(0, Math.floor(Math.random() * 3) + 1),
  }));
};

export const featuredMovies: Movie[] = generateMovies(5, 0);

export const categories: Category[] = [
  { id: 'trending', title: 'Trending Now', movies: generateMovies(10, 10) },
  { id: 'top10', title: 'Top 10 in Your Country', movies: generateMovies(10, 20) },
  { id: 'action', title: 'Action & Adventure', movies: generateMovies(10, 30) },
  { id: 'comedy', title: 'Comedies', movies: generateMovies(10, 40) },
  { id: 'drama', title: 'Dramas', movies: generateMovies(10, 50) },
  { id: 'scifi', title: 'Sci-Fi & Fantasy', movies: generateMovies(10, 60) },
  { id: 'horror', title: 'Horror', movies: generateMovies(10, 70) },
  { id: 'documentary', title: 'Documentaries', movies: generateMovies(10, 80) },
];

export const getMovieById = (id: number): Movie | undefined => {
  const allMovies = [...featuredMovies, ...categories.flatMap(c => c.movies)];
  return allMovies.find(m => m.id === id);
};
