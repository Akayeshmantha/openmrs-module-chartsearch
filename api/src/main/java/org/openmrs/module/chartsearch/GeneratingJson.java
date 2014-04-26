package org.openmrs.module.chartsearch;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
<<<<<<< HEAD
import org.openmrs.module.chartsearch.ChartListItem;
import org.openmrs.module.chartsearch.EncounterItem;
import org.openmrs.module.chartsearch.FormItem;
import org.openmrs.module.chartsearch.ObsItem;
import org.openmrs.module.chartsearch.SearchAPI;
=======
import org.openmrs.ConceptNumeric;
import org.openmrs.Obs;
import org.openmrs.api.context.Context;
import org.openmrs.util.Format;

import java.util.HashSet;
import java.util.Set;
>>>>>>> Json is working (not tested yet for obs groups) (should work only for obs.)

/**
 * Created by Eli on 16/03/14.
 */

public class GeneratingJson {
<<<<<<< HEAD
    public static String generateJson(){
        JSONObject json = new JSONObject();
        SearchAPI searchAPI =SearchAPI.getInstance();
        //switchCase - obs

        JSONObject observation;
        //JSONObject observations = new JSONObject();
        JSONArray arr_of_obs = new JSONArray();
        for(ChartListItem item : searchAPI.getResults()){
        	if(item instanceof  ObsItem){
                observation = new JSONObject();
                observation.put("date",((ObsItem) item).getObsDate());
                observation.put("obsGroupId",((ObsItem) item).getObsGroupId());
                observation.put("concept_name",((ObsItem) item).getConceptName());
                observation.put("value",((ObsItem) item).getValue());
                //json.put("observation", observation);
                //observation.put("locations",item.());   TODO
                arr_of_obs.add(observation);
        	}
        	
        	else if (item instanceof  FormItem){
                observation = new JSONObject();
                observation.put("date",((FormItem) item).getFormId());
                observation.put("concept_name",((FormItem) item).getEncounterType());
                observation.put("value",((FormItem) item).getFormName());
                //json.put("observation", observation);
                //observation.put("locations",item.());   TODO
                arr_of_obs.add(observation);
        	}
        	else if (item instanceof  EncounterItem){
                observation = new JSONObject();
                observation.put("date",((EncounterItem) item).getEncounterId());
                observation.put("concept_name",((EncounterItem) item).getEncounterType());
                observation.put("value",((EncounterItem) item).getUuid());
                //json.put("observation", observation);
                //observation.put("locations",item.());   TODO
                arr_of_obs.add(observation);
        	}
        }
        return arr_of_obs.toString();
    }
    
}
    
    
=======


    public static String generateJson() {

        JSONObject jsonToReturn = new JSONObject();  //returning this object
        JSONArray arr_of_groups = new JSONArray();


        for (Set<Obs> obsGrp : generateObsGroupFromSearchResults()) {
            JSONArray arr_of_obs = new JSONArray();
            JSONObject jsonObs = null;
            JSONObject jsonGrp = new JSONObject();
            for (Obs obs : obsGrp) {
                if (obs != null) {
                    jsonObs = createJsonObservation(obs);
                }
                arr_of_obs.add(jsonObs);
            }
            int obsGrpId = -1;
            if (obsGrp.iterator().hasNext()) {
                Obs thisObsGroup = obsGrp.iterator().next();
                obsGrpId = thisObsGroup.getObsId();

                jsonGrp.put("group_Id", obsGrpId);
                jsonGrp.put("group_name", thisObsGroup.getConcept().getDisplayString());
                String obsDate = thisObsGroup.getObsDatetime() == null ? "" : Format.format(thisObsGroup.getObsDatetime());
                jsonGrp.put("last_taken_date", obsDate);
                jsonGrp.put("observations", arr_of_obs);
                arr_of_groups.add(jsonGrp);
            }
        }


        jsonToReturn.put("obs_groups", arr_of_groups); //add the array to the json


        JSONObject jsonObs = null;
        JSONArray arr_of_obs = new JSONArray();
        for (Obs obsSingle : generateObsSinglesFromSearchResults()) {
            if (obsSingle != null) {
                jsonObs = createJsonObservation(obsSingle);
            }

            arr_of_obs.add(jsonObs);


        }
        jsonToReturn.put("obs_singles", arr_of_obs);


        return jsonToReturn.toString();
    }

    private static JSONObject createJsonObservation(Obs obs) {
        JSONObject jsonObs = new JSONObject();
        jsonObs.put("observation_id", obs.getObsId());
        jsonObs.put("concept_name", obs.getConcept().getDisplayString());

        String obsDate = obs.getObsDatetime() == null ? "" : Format.format(obs.getObsDatetime());
        jsonObs.put("date", obsDate);

        if (obs.getConcept().getDatatype().isNumeric()) { // ADD MORE DATATYPES
            jsonObs.put("value_type", obs.getConcept().getDatatype().getName());

            ConceptNumeric conceptNumeric = Context.getConceptService().getConceptNumeric(obs.getConcept().getId());
            jsonObs.put("units_of_measurement", conceptNumeric.getUnits());
            jsonObs.put("absolute_high", conceptNumeric.getHiAbsolute());
            jsonObs.put("absolute_low", conceptNumeric.getLowAbsolute());
            jsonObs.put("critical_high", conceptNumeric.getHiCritical());
            jsonObs.put("critical_low", conceptNumeric.getLowCritical());
            jsonObs.put("normal_high", conceptNumeric.getHiNormal());
            jsonObs.put("normal_low", conceptNumeric.getLowNormal());

        }
        jsonObs.put("value", obs.getValueAsString(Context.getLocale()));
        jsonObs.put("location", obs.getLocation().getDisplayString());
        return jsonObs;
    }


    public static Set<Set<Obs>> generateObsGroupFromSearchResults() {
        Set<Set<Obs>> obsGroups = new HashSet<Set<Obs>>();

        SearchAPI searchAPI = SearchAPI.getInstance();
        for (ChartListItem item : searchAPI.getResults()) {               //for each item in results we classify it by its obsGroup, and add all of the group.
            if (item != null) {
                int itemObsId = item.getObsId();
                // System.out.println("OUTSIDE" + Context.getObsService().getObs(itemObsId).getConcept().getDisplayString());

                if (Context.getObsService().getObs(itemObsId).getObsGroup() != null) {
                    // System.out.println("INSIDE OF IF" + Context.getObsService().getObs(itemObsId).getConcept().getDisplayString());
                    int groupId = Context.getObsService().getObs(itemObsId).getObsGroup().getId();


                    Set<Obs> obsGroup = Context.getObsService().getObs(itemObsId).getGroupMembers();

                    boolean found = false;                                      //if found == ture then we don't need to add the group.
                    for (Set<Obs> grp : obsGroups) {
                        Obs ob = new Obs(-1);

                        if (grp.iterator().hasNext()) {
                            ob = grp.iterator().next();
                        }

                        if (ob.getObsGroup().getId() == groupId) {
                            found = true;
                        }
                    }
                    if (!found) {
                        obsGroups.add(obsGroup);
                    }
                }
            }
        }

        return obsGroups;
    }

    public static Set<Obs> generateObsSinglesFromSearchResults() {
        SearchAPI searchAPI = SearchAPI.getInstance();
        Set<Obs> obsSingles = new HashSet<Obs>();
        for (ChartListItem item : searchAPI.getResults()) {
            if (item != null) {
                int itemObsId = item.getObsId();
                if (Context.getObsService().getObs(itemObsId).getObsGroup() == null && Context.getObsService().getObs(itemObsId) != null) {
                    obsSingles.add(Context.getObsService().getObs(itemObsId));
                }
            }


        }
        return obsSingles;
    }
}
>>>>>>> Json is working (not tested yet for obs groups) (should work only for obs.)
