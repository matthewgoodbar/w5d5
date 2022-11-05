def what_was_that_one_with(those_actors)
  # Find the movies starring all `those_actors` (an array of actor names).
  # Show each movie's title and id.

  Movie
    .joins(:actors)
    .where('actors.name IN (?)', those_actors)
    .group('movies.id')
    .having('COUNT(movies.id) = (?)', those_actors.length)
    .select('movies.title, movies.id')
  
end

def golden_age
  # Find the decade with the highest average movie score.
  # HINT: Use a movie's year to derive its decade. Remember that you can use
  # arithmetic expressions in SELECT clauses.

  Movie
    .select('(yr / 10) * 10 AS decade')
    .group('(yr / 10) * 10')
    .order('AVG(score) DESC')
    .limit(1).first.decade
end

def costars(name)
  # List the names of the actors that the named actor has ever appeared with.
  # Hint: use a subquery

  Actor.find_by(name: name).movies
    .joins(:actors)
    .where('actors.name != (?)', name).distinct
    .pluck(:name)

  # relevant_movies = Actor.find_by(name: name).movies.pluck(:id)

  
end

def actor_out_of_work
  # Find the number of actors in the database who have not appeared in a movie.
  
  Actor
    .left_outer_joins(:castings)
    .where(castings: {id: nil})
    .distinct.count
end

def starring(whazzername)
  # Find the movies with an actor who had a name like `whazzername`. A name is
  # like whazzername if the actor's name contains all of the letters in
  # whazzername, ignoring case, in order.

  # E.g., "Sylvester Stallone" is like "sylvester" and "lester stone" but not
  # like "stallone sylvester" or "zylvester ztallone".

  table = Actor.all.includes(:movies)
  names = table.distinct.pluck(:name)
  names.select! {|name| like(name, whazzername)}

  table.where('actors.name IN (?)', names)
  
  # Movie
  #   .joins(:actors)
  #   .where('actors.name IN (?)', names)
  
end

def like(actor_name, whazzername)
  temp = whazzername.dup.downcase
  actor_name.each_char.with_index do |char, i|
    if char.downcase == temp[0]
      temp = temp[1..-1]
    end
  end
  return true if temp == ""
  return false
end

def longest_career
  # Find the 3 actors who had the longest careers (i.e., the greatest time
  # between first and last movie). Order by actor names. Show each actor's id,
  # name, and the length of their career.

  Actor
    .joins(:movies)
    .group('actors.id')
    .order('career_length DESC')
    .limit(3)
    .select('actors.id, actors.name, (MAX(movies.yr) - MIN(movies.yr)) as career_length')
  
end