class PeopleController < ApplicationController
  
  around_filter :neo_tx
  layout 'layout', :except => [:graphml]
  
  def index
    @people = Person.all.nodes
  end
  
  def create
    @object = Neo4j::Person.new
    @object.update(params[:person])
    flash[:notice] = 'Person was successfully created.'
    redirect_to(people_url)
  end
  
  def update
    @object.update(params[:person])
    flash[:notice] = 'Person was successfully updated.'
    redirect_to(@object)
  end
  
  def destroy
    @object.delete
    redirect_to(people_url)
  end
  
  def edit
  end
  
  def graphml
  end
  
  def show
    @references = Reference.all.nodes
    @organisations = Organisation.all.nodes
    @people = Person.all.nodes
    @locations = Location.all.nodes
    @events = Event.all.nodes
    # prime filters for linked data retrieval
    @person_model = ["person_to_person","person_to_person","person_to_person"]
    @org_model = ["person_to_org","person_to_org","nil"]
    @loc_model = ["person_to_loc","person_to_loc","nil"]
    @event_model = ["person_to_event","person_to_event","nil"]
    @ref_model = ["person_to_ref","person_to_ref","nil"]
  end

  def link
    linker(params)
    redirect_to(@object)
    flash[:notice] = [@object.first_name, @object.surname].join(" ") + " was linked to node " + @target.neo_node_id.to_s
  end
  
  def unlink
    unlinker(params)
    redirect_to(@object)
    flash[:notice] = [@object.first_name, @object.surname].join(" ") + " was unlinked from " + @target.neo_node_id.to_s
  end
  
  def new
    @object = Person.value_object.new
  end
  
  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end