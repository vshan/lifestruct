json.array!(@asgn_goals) do |goal|
  json.extract! goal, :id, :title, :description, :start, :end
  json.url goal_url(goal, format: :html)
end