import Foundation
import UIKit


final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    
    func givenAnswer(givenAnswer: Bool) {
        
        let givenAnswer: Bool = true
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        if givenAnswer == true {
            viewController?.yesButton.isEnabled = false
            viewController?.noButton.isEnabled = false

            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    }
    
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        givenAnswer(givenAnswer: true)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        givenAnswer(givenAnswer: false)
    }
}
