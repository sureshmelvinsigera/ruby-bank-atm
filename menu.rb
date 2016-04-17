require_relative 'menu'
require_relative 'user'
require_relative 'feature'

class Menu
  @@ljustNum = 40
  @@rjustNum = 3
  @@border = 47  

  def self.appname
    "DSC Bank ATM"
  end

  def self.welcome
    puts "\nWelcome to #{self.appname}."
    customers = Feature.storedData
    Feature.authenticationCard(customers)
  end

  def self.mainMenuChoices
    [
      "Instructions",
      "Print Balance",
      "Print Transactions",
      "Transfer Funds",
      "Deposit",
      "Cash Withdrawal",
      "Cash Advance",
      "Make Payment"
    ]
  end

  def self.transactionChoices
    [
      "Deposit",
      "Payment",
      "Transfer Funds",
      "Cash Withdrawal",
      "Cash Advance"
    ]
  end

  def self.printInstructions
    x=0
    puts 'Please select from the following:'
    puts '-' * @@border
    puts 'Description'.ljust(@@ljustNum)  + 'Command'.rjust(@@rjustNum)
    Menu.mainMenuChoices.each {|menuList|
      puts menuList.ljust(@@ljustNum,'.') + "#{x+=1}".rjust(@@rjustNum)
    }
    puts 'Exit'.ljust(@@ljustNum,'.')        + 'x'.rjust(@@rjustNum)
    puts '-' * @@border
  end

  def printMainLoop(customer)
    user_choice = ''
    loop do user_choice != 'x'
      i = 0
      print 'Enter Command (or 1 for menu, x to exit): '
      user_choice = gets.chomp.to_s.downcase

      case user_choice
      when "#{i+=1}".to_s then Menu.printInstructions
      when "#{i+=1}".to_s #print balance
        Menu.printBalance(customer)
      when "#{i+=1}".to_s #print transactions
        Menu.printTransactions(customer)
      when "#{i+=1}".to_s #transfer funds
        Menu.printTransferFunds(customer)
      when "#{i+=1}".to_s #deposit
        Menu.printDeposit(customer)
      when "#{i+=1}".to_s #cash withdrawal
        Menu.printWithdrawalCash(customer)
      when "#{i+=1}".to_s #cash advance
        Menu.printWithdrawalCashAdvance(customer)
      when "#{i+=1}".to_s #payment
        Menu.printPayment(customer)
      when 'x' #save data and exit
        Feature.getStoredDataAndSave(customer)
        Menu.printGoodbye
      else
        puts 'Invalid Choice.'
        Menu.printInstructions
      end

      break if user_choice == 'x'
    end      
  end

  def self.printATMcardAuthentication
    puts "Please enter your ATM card."
    # atmCardId = gets.chomp
    atmCardId = "80e711df-8c8d-4d1b-871e-7e1528675d11"
  end

  def self.printATMcardPinAuthentication
    puts 'Enter your pin:'
    # pinEntry = gets.chomp
    pinEntry = "1174"
  end

  def self.printUserAccounts(item1, item2, choice)
    "#{item1}-#{item2}".ljust(@@ljustNum,'.') + "#{choice}".rjust(@@rjustNum)
  end

  def self.printAccountbyType(customer, accountTypes = [])
    choices = User.getUserAccountsByType(customer, accountTypes) #plural
    puts 'Choose Account:'.ljust(@@ljustNum,'.')        + 'Choice'.rjust(@@rjustNum)
    puts '-' * @@border
    puts choices[0]
    puts '-' * @@border
    User.getUserAccount(choices[1]) #single
  end

  def self.printBalance(customer)
    account = Menu.printAccountbyType(customer)
    if account == false
      puts "Invalid Choice"
    else
      puts "#{account[:accountType]}-#{account[:accountNum]}"
      puts "Your Balance is: #{User.getUserAccountBalance(account)}"
    end
  end

  def self.printTransactions(customer)
    account = Menu.printAccountbyType(customer)
    if account == false
      puts "Invalid Choice"
    else
      puts "Transactions for: #{account[:accountType]}-#{account[:accountNum]}"
      transactions = User.getUserAccountTransactions(account)
      padding = 15
      transactions.each {|transaction| 
        puts "#{transaction[:date]}".ljust(padding) + 
              " #{transaction[:transactionType]}".ljust(padding) + 
              " #{transaction[:amount]}".ljust(padding) +
              " #{transaction[:comment]}".rjust(padding)
      }
    end
  end

  def self.printTransferFunds(customer)
    #Note: Prof requested to be able to transfer funds between 'ANY' two accounts
    puts "\nSelect account to transfer funds from: "
    fromAccount = Menu.printAccountbyType(customer)
    puts "\nSelect account to transfer funds to: "
    toAccount = Menu.printAccountbyType(customer)
    if fromAccount == false || toAccount == false
      puts "Invalid Choice"
    else
      # dailyTransactions Limit
      if Feature.dailyTransactionLimit(toAccount) == true || Feature.dailyTransactionLimit(fromAccount) == true
        puts "Declined: You have reached your daily transaction limit."
      else
        print "How much? "; amount = gets.chomp.to_f
        Feature.transfer(fromAccount, toAccount, amount)
        puts "Transfered $#{amount} from: #{fromAccount[:accountType]}-#{fromAccount[:accountNum]} to: #{toAccount[:accountType]}-#{toAccount[:accountNum]} "
      end
    end
  end

  def self.printDeposit(customer)
    account = Menu.printAccountbyType(customer)
    if account == false
      puts "Invalid Choice"
    else
      # dailyTransactions Limit
      if Feature.dailyTransactionLimit(account) == true
        puts "Declined: You have reached your daily transaction limit."
      else
        print "How much? "; amount = gets.chomp.to_f
        Feature.deposit(account, amount)
        puts "Deposited $#{amount} to: #{account[:accountType]}-#{account[:accountNum]} "
      end
    end
  end

  def self.printWithdrawalCash(customer)
    #only on checking or savings
    account = Menu.printAccountbyType(customer, ["Checking", "Savings"])
    if account == false
      puts "Invalid Choice"
    else
      #max $500 withdrawal per account per day
      # dailyTransactions Limit
      if Feature.dailyTransactionLimit(account) == true
        puts "Declined: You have reached your daily transaction limit."
      elsif Feature.dailyWithdrawalLimit(account) == true
        puts "Declined: You have reached your daily cash withdrawal limit."
      else
        print "How much? "; amount = gets.chomp.to_f
        if (amount + Feature.totalWithdrawalsToday(account)) > Feature.dailyWithdrawalLimitAmount
          puts "Declined: This transaction will take take you above your daily cash withdrawal limit."
        else
          Feature.withdrawalCash(account, amount)
          puts "Withdrew $#{amount} from: #{account[:accountType]}-#{account[:accountNum]} "
        end
      end
    end
  end

  def self.printWithdrawalCashAdvance(customer)
    #only on credit card
    account = Menu.printAccountbyType(customer, ["Credit Card"])
    if account == false
      puts "Invalid Choice"
    else
      #max withdrawal per account per day
      #max withdrawal is credit limit
      # dailyTransactions Limit
      if Feature.dailyTransactionLimit(account) == true
        puts "Declined: You have reached your daily transaction limit."
      else
        print "How much? "; amount = gets.chomp.to_f
        if (amount + User.getUserAccountBalance(account)) > account[:creditLimit]
          puts "Declined: This transaction will take you over your credit limit."
        elsif (amount + Feature.totalWithdrawalsToday(account)) > Feature.dailyWithdrawalLimitAmount
          puts "Declined: You have reached your daily cash withdrawal limit."
        else
          Feature.withdrawalCashAdvance(account, amount)
          puts "Withdrew $#{amount} from: #{account[:accountType]}-#{account[:accountNum]} "
        end
      end
    end
  end

  def self.printPayment(customer)
    #only from checking or savings
    puts "\nSelect account to transfer funds from: "
    fromAccount = Menu.printAccountbyType(customer, ["Checking", "Savings"])
    puts "\nSelect account to transfer funds to: "
    #only to Mortgage and Car Loan
    toAccount = Menu.printAccountbyType(customer, ["Mortgage", "Car Loan"])
    if fromAccount == false || toAccount == false
      puts "Invalid Choice"
    else    
      # dailyTransactions Limit
      if Feature.dailyTransactionLimit(toAccount) == true || Feature.dailyTransactionLimit(fromAccount) == true
        puts "Declined: You have reached your daily transaction limit."
      else
        print "How much? "; amount = gets.chomp.to_f
        Feature.payment(fromAccount, toAccount, amount)
        puts "Payment of $#{amount} from: #{fromAccount[:accountType]}-#{fromAccount[:accountNum]} to: #{toAccount[:accountType]}-#{toAccount[:accountNum]} "
      end
    end
  end

  def self.printGreeting(first_name, last_name)
    puts "\nHello #{first_name} #{last_name}"
  end

  def self.printGoodbye
    puts "Thank you for using #{appname}. \nGoodbye!\n\n"
  end
end
