#pragma once
#include<bits/stdc++.h>
#include "1905027_SymbolInfo.h"
#include "1905027_ScopeTable.h"
using namespace std;

class Symbol_Table
{
private:
    Scope_Table *curr;
    int Scope_num_buckets;
    int size=1;

public:

    Symbol_Table(int len)
    {

        Scope_num_buckets=len;
        curr=new Scope_Table(size++,len,nullptr);

    }

    ~Symbol_Table()
    {
        Scope_Table *temp=curr;
        while (temp!=nullptr)
        {
            curr=curr->getParent();
            delete temp;
            temp=curr;
        }

    }

    void Enter_Scope()
    {

        curr=new Scope_Table(size++,Scope_num_buckets,curr);
    }

    void Exit_Scope()
    {
        if(curr->getParent()==nullptr)
        {
            // cout<<"\tScopeTable# "<<curr->getID()<<" cannot be removed\n";
            return;
        }
        // Scope_Table *temp=curr;
        curr=curr->getParent();
        // cout<<"\tScopeTable# "<<temp->getID()<<" removed\n";
        // delete temp;
    }

    void ExitAllScope()
    {

        while(curr!=nullptr)
        {
            // Scope_Table *temp=curr;
            curr=curr->getParent();
            // cout<<"\tScopeTable# "<<temp->getID()<<" removed\n";
            // delete temp;
        }
    }

    bool Insert(string name,string type)
    {
        if(curr==nullptr)curr=new Scope_Table(size++,Scope_num_buckets,nullptr);
        return curr->InsertSymbol(name,type); 
    }

    bool Remove(string name)
    {
        if(curr==nullptr)return false;
        return curr->delete_Symbol(name);
    }

    Symbol_Info *Lookup(string name)
    {
        if(curr==nullptr)return nullptr;

        Symbol_Info *result=curr->LookUpSymbol(name);
        if(result==nullptr)
        {
            Scope_Table *temp=curr->getParent();
            while(temp!=nullptr)
            {
                result=temp->LookUpSymbol(name);
                if(result!=nullptr)break;
                temp=temp->getParent();

            }
        }

        // if(result==nullptr)cout<<"\t'"<<name<<"' not found in any of the ScopeTables\n";
        return result;

    }

    void PrintCurrScope()
    {
        if(curr==nullptr)return;
        curr->Print_ScopeTable();
    }

    void PrintAllScope()
    {
        if(curr==nullptr)return;
        Scope_Table *temp=curr;
        while (temp!=nullptr)
        {
            temp->Print_ScopeTable();
            temp=temp->getParent();

        }
    }


};
