# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  #pending  # Remove this statement when you finish implementing the test step
  movies_table.hashes.each do |movie|
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
    Movie.create!({title:movie[:title],rating:movie[:rating],release_date:movie[:release_date]})
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
#  pending  #remove this statement after implementing the test step
  rating_list = arg1.gsub(/\s+/,'').split(',')
  all_rating = ['PG','G','PG-13','NC-17','R']
  all_rating.each do |rating|
    if rating_list.include?(rating)
      check 'ratings_'+rating
    else
      uncheck 'ratings_'+rating
    end
  end
  click_button('Refresh')
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
 # pending  #remove this statement after implementing the test step

   ratings = arg1.upcase.gsub(/\s+/,'').split(',') 
   ratings = ratings.uniq
   moviesSelect = []
   ratings.each do |rate|
     moviesSelect = moviesSelect+ Movie.where(rating:rate)
   end
   value = moviesSelect.size
   rows = all("tr").size-1
   rows.should == value
   

  
   result = false
   moviesSelect.each do |movie|
       result=false
       all("tr").each do |tr|
         if tr.has_content?(movie[:title]) && tr.has_content?(movie[:rating])
           result = true
           break
         end
       end
       if result==false
          break
       end  
   end
  expect(result).to be_truthy
end

Then /^I should see all of the movies$/ do
  #pending  #remove this statement after implementing the test step
  numMovies = Movie.all.size
  rows = all("tr").size-1
  rows.should == numMovies 

end

 When /^I have sorted movies alphabetically$/ do
   click_link('title_header')
 end
 When /^I have sorted movies in increasing order of release date$/ do
  click_link('release_date_header')
 end

 Then /^I should see "(.*?)" before "(.*?)"$/ do |title1, title2|
   result = true
   allMovies = page.body
   firstIndex = /#{title1}/ =~ allMovies
   secondIndex = /#{title2}/ =~ allMovies
   if(secondIndex<firstIndex)
     result = false
   end
   expect(result).to be_truthy

 end 

