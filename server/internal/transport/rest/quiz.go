package rest

type CreateQuizRequest struct {
    Title       string            `json:"title" binding:"required"`
    Description string            `json:"description"`
    TimeLimit   int               `json:"timeLimit" binding:"required"`
    Difficulty  string            `json:"difficulty" binding:"required,oneof=Easy Medium Hard"`
    Questions   []QuestionRequest `json:"questions" binding:"required,min=1"`
    Topics      []string          `json:"topics"`
}

type QuestionRequest struct {
	QuestionText string `json:"text" binding:"required"`
	Points int `json:"points" binding:"required"`
	Options []OptionRequest `json:"options" binding:"required,min=2"`
}

type OptionRequest struct {
	OptionText string `json:"optionText" binding:"required"`
	IsCorrect bool `json:"isCorrect"`
}

type QuizAttemptRequest struct {
	QuizID  uint         `json:"quizId" binding:"required"`
	Answers []AnswerRequest `json:"answers" binding:"required"`
}

type AnswerRequest struct {
	QuestionID uint `json:"questionId" binding:"required"`
	OptionID   uint `json:"optionId" binding:"required"`
}
