## Automatic Teller Machine (ATM)
This is the code part of a Automatic Teller Machine term project at DSC. Written in ruby.

### Getting Started
Ruby is already installed on many OSX and Linux systems. If not, you can install it on Ubuntu systems by running: ```sudo apt-get install ruby-full``` or for other systems check out [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/ "Installing Ruby").  
To run the program, do the following:  

1. Download the zip file and unzip.  
2. Open a terminal in the project folder and type the following:
```
ruby start.rb
```  

### Testing as a customer
Follow the on-screen prompts to test. If you want to change the customers, look at the seed.rb file with customers and accounts. Here are the 3 default customers:

**Ken Doe**  
ATM Card:  
92f086dd-a76a-4bae-81a4-8f3694f5d478  
Pin:  
3293

**Frank Smith**  
ATM Card:  
0df20751-e24f-481b-9b75-8c26efee3198  
Pin:  
5690  

**Jane English**  
ATM Card:  
80e711df-8c8d-4d1b-871e-7e1528675d11  
Pin:   
1174  


### Notes
Some prompts may be commented out and replaced with hard code while in progress.  
Entering in the wrong ATM Card key once will exit program.  
Entering in the wrong Pin 3 times will exit program.  

Error handling for many features have not been requested or added including:  

- Checking available funds when making payment from account  
- Unacceptable key entry not relevant to presented menu list item