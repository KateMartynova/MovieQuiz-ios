import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Private Properties
    
    private let button = UIButton()
    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        
        questionFactory?.loadData()
        
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        statisticService = StatisticServiceImplementation()
    
    }
    
    // MARK: - Private Methods

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true

        }
    }
    
    
    private func givenAnswer(givenAnswer: Bool) {
        
        let givenAnswer: Bool = true
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        if givenAnswer == true {
            yesButton.isEnabled = false
            noButton.isEnabled = false

            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    }
    
    
    private func showQuizResults() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(/*accessibilityIdentifier: "Test",*/
                                    title: "Этот раунд окончен!",
                                    message: resultMessage(),
                                    buttonText: "Сыграть ещё раз",
                                    completion: { [weak self] in
            guard let self = self else {
                return
            }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
            
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
   
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showQuizResults()
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    
    func resultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let totalGamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResult = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"
        let bestGameInfo = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResult, totalGamesCount, bestGameInfo, averageAccuracy].joined(separator: "\n")
        
        return resultMessage
    }
    
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()

    }

    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        givenAnswer(givenAnswer: false)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        givenAnswer(givenAnswer: true)
    }
}

