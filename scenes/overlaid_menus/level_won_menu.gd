extends LevelWonMenu


func setup(level_state: LevelState):
	%ScoreLabel.text = str(level_state.score)

	if level_state.score == level_state.highscore:
		%NewHighscoreMagin.show()
		%HighscoreMagin.hide()
	else:
		%NewHighscoreMagin.hide()
		%HighscoreMagin.show()
		%HighscoreLabel.text = "highscore: " + str(level_state.highscore)
