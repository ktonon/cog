#include "Dog.h"
#include <iostream>

using namespace std;

int main(int argc, char** argv)
{
    Animals::Dog dog;
    cout << "A dog says: " << dog.speak("hungry!") << endl;
    return 0;
}
