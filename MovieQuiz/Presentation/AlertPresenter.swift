import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak movieQuiz] _ in
            guard let movieQuiz = movieQuiz else { return }
            
            movieQuiz.currentQuestionIndex = 0
            movieQuiz.correctAnswers = 0
            
            movieQuiz.questionFactory?.requestNextQuestion()
        }
        
        
        alert.addAction(action)
        
        movieQuiz.present(alert, animated: true, completion: nil)
    }
    
    var movieQuiz: MovieQuizViewController
    
    init(movieQuiz: MovieQuizViewController) {
        self.movieQuiz = movieQuiz
    }
}
