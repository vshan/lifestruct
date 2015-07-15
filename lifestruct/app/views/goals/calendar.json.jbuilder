json.array!(@asgn_goals) do |goal|
  json.extract! goal, :id, :title, :description, :start, :end, :repeatable
  json.backgroundColor goal.background_color
  json.borderColor goal.border_color
  json.url goal_url(goal, format: :html)
end