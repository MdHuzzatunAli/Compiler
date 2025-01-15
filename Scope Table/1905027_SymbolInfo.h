#pragma once
#include<bits/stdc++.h>
using namespace std;

class Symbol_Info{

private:
    string name;
    string type;
    Symbol_Info *nxtptr;

    // int start_line;
    // int end_line;
    // vector<Symbol_Info*> children;

    //if variable datatype , if function return type
    string data_type;
    //classification variable, func declaration, func definition
    string info_type;
    string array_length;
    vector <Symbol_Info*> params;


public:

    Symbol_Info(string name, string type)
    {
        this->name=name;
        this->type=type;
        nxtptr=nullptr;
        data_type="";
        info_type="VARIABLE";
        array_length="";
        params.clear();
        // children.clear();
    }

    Symbol_Info(Symbol_Info *symbol)
    {
        name=symbol->name;
        type=symbol->type;
        nxtptr=symbol->nxtptr;
        data_type=symbol->data_type;
        info_type=symbol->info_type;
        array_length=symbol->array_length;
        params=symbol->params;
        // children=symbol->children;
        // start_line=symbol->start_line;
        // end_line=symbol->end_line;


    }

    Symbol_Info(string name,string type,string data_type,string info_type="VARIABLE",string array_length="")
    {
        this->name=name;
        this->type=type;
        this->nxtptr=nullptr;
        this->data_type=data_type;
        this->info_type=info_type;
        params.clear();
        // children.clear();
    }

    Symbol_Info(const Symbol_Info &symbol)
    {
        this->name=symbol.name;
        this->type=symbol.type;
        this->nxtptr=symbol.nxtptr;
        this->data_type=symbol.data_type;
        this->info_type=symbol.info_type;
        this->params=symbol.params;
        this->array_length=symbol.array_length;
        // this->children=symbol.children;
        // this->start_line=symbol.start_line;
        // this->end_line=symbol.end_line;

    }


    string getName() 
    {
        return name;
    }

    string getType() 
    {
        return type;
    }

    Symbol_Info *get_nxtptr() {
        return nxtptr;
    }

    void setName(string name)
    {
        this->name=name;
    }

    void setType(string type)
    {
        this->type=type;
    }

    void set_nxtptr(Symbol_Info *nxtptr)
    {
        this->nxtptr=nxtptr;
    }



    friend ostream &operator<<(ostream& o, Symbol_Info& syminfo)
    {
        // o<<"<"<<syminfo.name<<","<<syminfo.data_type<<">";
        if(syminfo.name!="main"){
        o<<"<"<<syminfo.name;
        if(syminfo.is_Func())o<<","<<"FUNCTION";
        // else o<<","<<syminfo.info_type;       
        if(syminfo.is_array())o<<",ARRAY>";
        else if(syminfo.data_type=="float")o<<",FLOAT>";
        else if(syminfo.data_type=="void")o<<",VOID>";
        else if(syminfo.data_type=="int")o<<",INT>";
        else o<<",INT"<<">";
        }
        
        

        return o;
    }

    void add_Param(Symbol_Info *symbol)
    {
        params.push_back(symbol);
    }

    void set_Param(vector <Symbol_Info*> params)
    {
        this->params=params;
    }

    vector<Symbol_Info*> get_Params()
    {
        return params;
    }

    void set_return_type(string data_type)
    {
        this->data_type=data_type;
    }

    string get_return_type()
    {
        return data_type;
    }


    bool is_Func()
    {
        return info_type=="FUNCTION_DECLARATION"||info_type=="FUNCTION_DEFINITION";
    }

    string get_array_length()
    {
        return array_length;
    }

    void set_array_length(string array_length)
    {
        this->array_length=array_length;
    }

    bool is_array()
    {
        bool temp=true;
        if(array_length=="")temp=false;
        return temp;
    }

    string get_info_type()
    {
        return info_type;
    }

    void set_info_type(string info_type)
    {
        this->info_type=info_type;
    }

    string get_data_type()
    {
        return data_type;
    }

    void set_data_type(string data_type)
    {
        this->data_type=data_type;
    }



};


class TreeNode{
    public:
        Symbol_Info *symbol;
        vector<Symbol_Info*> Nodes_param_list;
        string output_text;
        vector <TreeNode*> childlist;
        int first_line,last_line;
        bool is_Terminal;

        TreeNode(Symbol_Info *symbol,string output_text)
        {
            this->symbol=symbol;
            // Nodes_param_list=nullptr;
            this->output_text=output_text;
        }

         void printchildren(int space,ofstream &parserout)
         {
            if(is_Terminal)parserout<<output_text<<endl;
            else parserout<<output_text<<" \t<Line: "<<first_line<<"-"<<last_line<<">"<<endl;
            for (int i = 0; i < childlist.size(); i++)
            {
                for (int j = 0; j < space; j++)
                {
                    parserout<<" ";
                }
                childlist[i]->printchildren(space+1,parserout);
            }
            
         }

        

};