require 'game_constants'
require 'tournament_info'
require 'ftools'

begin_document = '\documentclass[10pt]{article}
                       \pagestyle{empty}
                       \begin{document}
                         \begin{displaymath}'
formula = TournamentInfo.objective_function
end_document =    '\end{displaymath}
                    \end{document}'

File.open("formula", 'w' ) do |out|
  out.write("#{begin_document}#{formula}#{end_document}")
end
`./textogif -res 0.1 -png formula`
File.move("formula.png", FormulaLocation)
File.delete("formula")
