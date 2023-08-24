import Foundation
import UIKit


final class MovieQuizPresenter {
    
    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    var alertPresenter: AlertPresenterProtocol?
    
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
    
    
    func givenAnswer(isYes: Bool) {
        
        let givenAnswer = isYes
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked(_ sender: UIButton) {
        givenAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        givenAnswer(isYes: false)
    }
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            showQuizResults()
        } else {
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    
    func showQuizResults() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: resultMessage(),
                                    buttonText: "Сыграть ещё раз",
                                    completion: { [weak self] in
            guard let self = self else {
                return
            }
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
            
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    
    func resultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let totalGamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResult = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfo = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResult, totalGamesCount, bestGameInfo, averageAccuracy].joined(separator: "\n")
        
        return resultMessage
    }
}
